#include "PlanModel.h"
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

PlanModel::PlanModel(QObject *parent)
    : QAbstractListModel(parent)
{
    initDatabase();
    loadPlans();
}

void PlanModel::initDatabase()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QString dbPath = path + QStringLiteral("/gymlogger.db");

    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
    db.setDatabaseName(dbPath);

    if (!db.open()) {
        qWarning() << "Failed to open database:" << db.lastError().text();
        return;
    }

    QSqlQuery query(db);
    query.exec(QStringLiteral(
        "CREATE TABLE IF NOT EXISTS plans ("
        "  id INTEGER PRIMARY KEY,"
        "  name TEXT NOT NULL,"
        "  workouts TEXT NOT NULL DEFAULT '[]',"
        "  reminder_days TEXT NOT NULL DEFAULT '[]',"
        "  reminder_time TEXT NOT NULL DEFAULT ''"
        ")"
    ));
}

void PlanModel::loadPlans()
{
    QSqlQuery query;
    query.exec(QStringLiteral("SELECT id, name, workouts, reminder_days, reminder_time FROM plans ORDER BY id"));

    while (query.next()) {
        Plan plan;
        plan.id = query.value(0).toInt();
        plan.name = query.value(1).toString();

        QJsonDocument workoutsDoc = QJsonDocument::fromJson(query.value(2).toByteArray());
        for (const auto &item : workoutsDoc.array())
            plan.workouts.append(item.toObject().toVariantMap());

        QJsonDocument daysDoc = QJsonDocument::fromJson(query.value(3).toByteArray());
        for (const auto &item : daysDoc.array())
            plan.reminderDays.append(item.toString());

        plan.reminderTime = query.value(4).toString();

        m_plans.append(plan);
    }

    Q_EMIT countChanged();
}

void PlanModel::savePlan(const Plan &plan)
{
    QJsonArray workoutsArr;
    for (const QVariant &w : plan.workouts)
        workoutsArr.append(QJsonObject::fromVariantMap(w.toMap()));

    QJsonArray daysArr;
    for (const QString &d : plan.reminderDays)
        daysArr.append(d);

    QSqlQuery query;
    query.prepare(QStringLiteral(
        "INSERT INTO plans (id, name, workouts, reminder_days, reminder_time) "
        "VALUES (?, ?, ?, ?, ?)"
    ));
    query.addBindValue(plan.id);
    query.addBindValue(plan.name);
    query.addBindValue(QJsonDocument(workoutsArr).toJson(QJsonDocument::Compact));
    query.addBindValue(QJsonDocument(daysArr).toJson(QJsonDocument::Compact));
    query.addBindValue(plan.reminderTime);

    if (!query.exec())
        qWarning() << "Failed to save plan:" << query.lastError().text();
}

void PlanModel::deletePlanFromDb(int planId)
{
    QSqlQuery query;
    query.prepare(QStringLiteral("DELETE FROM plans WHERE id = ?"));
    query.addBindValue(planId);

    if (!query.exec())
        qWarning() << "Failed to delete plan:" << query.lastError().text();
}

void PlanModel::updatePlanInDb(const Plan &plan)
{
    QJsonArray workoutsArr;
    for (const QVariant &w : plan.workouts)
        workoutsArr.append(QJsonObject::fromVariantMap(w.toMap()));

    QJsonArray daysArr;
    for (const QString &d : plan.reminderDays)
        daysArr.append(d);

    QSqlQuery query;
    query.prepare(QStringLiteral(
        "UPDATE plans SET name = ?, workouts = ?, reminder_days = ?, reminder_time = ? "
        "WHERE id = ?"
    ));
    query.addBindValue(plan.name);
    query.addBindValue(QJsonDocument(workoutsArr).toJson(QJsonDocument::Compact));
    query.addBindValue(QJsonDocument(daysArr).toJson(QJsonDocument::Compact));
    query.addBindValue(plan.reminderTime);
    query.addBindValue(plan.id);

    if (!query.exec())
        qWarning() << "Failed to update plan:" << query.lastError().text();
}

int PlanModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_plans.size();
}

QVariant PlanModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_plans.size())
        return {};

    const Plan &plan = m_plans.at(index.row());

    switch (role) {
    case PlanIdRole:
        return plan.id;
    case PlanNameRole:
        return plan.name;
    case PlanWorkoutsRole:
        return plan.workouts;
    case ReminderDaysRole:
        return plan.reminderDays;
    case ReminderTimeRole:
        return plan.reminderTime;
    default:
        return {};
    }
}

QHash<int, QByteArray> PlanModel::roleNames() const
{
    return {
        {PlanIdRole, "planId"},
        {PlanNameRole, "planName"},
        {PlanWorkoutsRole, "planWorkouts"},
        {ReminderDaysRole, "reminderDays"},
        {ReminderTimeRole, "reminderTime"}
    };
}

int PlanModel::addPlan(const QString &name,
                       const QVariantList &workouts,
                       const QStringList &reminderDays,
                       const QString &reminderTime)
{
    int id = QDateTime::currentMSecsSinceEpoch();
    Plan plan{id, name, workouts, reminderDays, reminderTime};

    int row = m_plans.size();
    beginInsertRows(QModelIndex(), row, row);
    m_plans.append(plan);
    endInsertRows();

    savePlan(plan);
    Q_EMIT countChanged();
    return id;
}

void PlanModel::removePlan(int planId)
{
    for (int i = 0; i < m_plans.size(); ++i) {
        if (m_plans[i].id == planId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_plans.removeAt(i);
            endRemoveRows();

            deletePlanFromDb(planId);
            Q_EMIT countChanged();
            return;
        }
    }
}

void PlanModel::updatePlan(int planId,
                           const QString &name,
                           const QVariantList &workouts,
                           const QStringList &reminderDays,
                           const QString &reminderTime)
{
    for (int i = 0; i < m_plans.size(); ++i) {
        if (m_plans[i].id == planId) {
            m_plans[i].name = name;
            m_plans[i].workouts = workouts;
            m_plans[i].reminderDays = reminderDays;
            m_plans[i].reminderTime = reminderTime;

            updatePlanInDb(m_plans[i]);
            Q_EMIT dataChanged(index(i), index(i));
            return;
        }
    }
}

QVariantList PlanModel::getPlanWorkouts(int planId) const
{
    for (const Plan &plan : m_plans) {
        if (plan.id == planId)
            return plan.workouts;
    }
    return {};
}

QVariantMap PlanModel::getPlan(int planId) const
{
    for (const Plan &plan : m_plans) {
        if (plan.id == planId) {
            return {
                {QStringLiteral("planId"), plan.id},
                {QStringLiteral("planName"), plan.name},
                {QStringLiteral("planWorkouts"), plan.workouts},
                {QStringLiteral("reminderDays"), plan.reminderDays},
                {QStringLiteral("reminderTime"), plan.reminderTime}
            };
        }
    }
    return {};
}

int PlanModel::count() const
{
    return m_plans.size();
}
