#include "PlanModel.h"
#include <QDateTime>

PlanModel::PlanModel(QObject *parent)
    : QAbstractListModel(parent)
{
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
    int row = m_plans.size();

    beginInsertRows(QModelIndex(), row, row);
    m_plans.append({id, name, workouts, reminderDays, reminderTime});
    endInsertRows();

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
            Q_EMIT countChanged();
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

int PlanModel::count() const
{
    return m_plans.size();
}
