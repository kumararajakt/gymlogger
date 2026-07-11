#include "SessionModel.h"
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSet>
#include <QDebug>

SessionModel::SessionModel(QObject *parent)
    : QAbstractListModel(parent)
{
    initDatabase();
    loadSessions();
}

void SessionModel::initDatabase()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QString dbPath = path + QStringLiteral("/gymlogger.db");

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
        db.setDatabaseName(dbPath);
        if (!db.open()) {
            qWarning() << "Failed to open database:" << db.lastError().text();
            return;
        }
    }

    QSqlQuery query(db);
    query.exec(QStringLiteral(
        "CREATE TABLE IF NOT EXISTS sessions ("
        "  id INTEGER PRIMARY KEY,"
        "  plan_name TEXT NOT NULL,"
        "  workouts TEXT NOT NULL DEFAULT '[]',"
        "  duration_seconds INTEGER NOT NULL DEFAULT 0,"
        "  date_time TEXT NOT NULL DEFAULT ''"
        ")"
    ));
}

void SessionModel::loadSessions()
{
    QSqlQuery query;
    query.exec(QStringLiteral("SELECT id, plan_name, workouts, duration_seconds, date_time FROM sessions ORDER BY id DESC"));

    while (query.next()) {
        Session session;
        session.id = query.value(0).toInt();
        session.planName = query.value(1).toString();

        QJsonDocument workoutsDoc = QJsonDocument::fromJson(query.value(2).toByteArray());
        for (const auto &item : workoutsDoc.array())
            session.workouts.append(item.toObject().toVariantMap());

        session.durationSeconds = query.value(3).toInt();
        session.dateTime = query.value(4).toString();

        m_sessions.append(session);
    }

    Q_EMIT countChanged();
}

void SessionModel::saveSession(const Session &session)
{
    QJsonArray workoutsArr;
    for (const QVariant &w : session.workouts)
        workoutsArr.append(QJsonObject::fromVariantMap(w.toMap()));

    QSqlQuery query;
    query.prepare(QStringLiteral(
        "INSERT INTO sessions (id, plan_name, workouts, duration_seconds, date_time) "
        "VALUES (?, ?, ?, ?, ?)"
    ));
    query.addBindValue(session.id);
    query.addBindValue(session.planName);
    query.addBindValue(QJsonDocument(workoutsArr).toJson(QJsonDocument::Compact));
    query.addBindValue(session.durationSeconds);
    query.addBindValue(session.dateTime);

    if (!query.exec())
        qWarning() << "Failed to save session:" << query.lastError().text();
}

void SessionModel::deleteSessionFromDb(int sessionId)
{
    QSqlQuery query;
    query.prepare(QStringLiteral("DELETE FROM sessions WHERE id = ?"));
    query.addBindValue(sessionId);

    if (!query.exec())
        qWarning() << "Failed to delete session:" << query.lastError().text();
}

int SessionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_sessions.size();
}

QVariant SessionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_sessions.size())
        return {};

    const Session &session = m_sessions.at(index.row());

    switch (role) {
    case SessionIdRole:
        return session.id;
    case SessionPlanNameRole:
        return session.planName;
    case SessionWorkoutsRole:
        return session.workouts;
    case SessionDurationRole:
        return session.durationSeconds;
    case SessionDateTimeRole:
        return session.dateTime;
    default:
        return {};
    }
}

QHash<int, QByteArray> SessionModel::roleNames() const
{
    return {
        {SessionIdRole, "sessionId"},
        {SessionPlanNameRole, "sessionPlanName"},
        {SessionWorkoutsRole, "sessionWorkouts"},
        {SessionDurationRole, "sessionDuration"},
        {SessionDateTimeRole, "sessionDateTime"}
    };
}

int SessionModel::addSession(const QString &planName,
                             const QVariantList &workouts,
                             int durationSeconds)
{
    int id = QDateTime::currentMSecsSinceEpoch();
    QString dateTime = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd HH:mm"));
    Session session{id, planName, workouts, durationSeconds, dateTime};

    int row = 0;
    beginInsertRows(QModelIndex(), row, row);
    m_sessions.prepend(session);
    endInsertRows();

    saveSession(session);
    Q_EMIT countChanged();
    return id;
}

void SessionModel::removeSession(int sessionId)
{
    for (int i = 0; i < m_sessions.size(); ++i) {
        if (m_sessions[i].id == sessionId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_sessions.removeAt(i);
            endRemoveRows();

            deleteSessionFromDb(sessionId);
            Q_EMIT countChanged();
            return;
        }
    }
}

QVariantMap SessionModel::getSession(int sessionId) const
{
    for (const Session &session : m_sessions) {
        if (session.id == sessionId) {
            return {
                {QStringLiteral("sessionId"), session.id},
                {QStringLiteral("sessionPlanName"), session.planName},
                {QStringLiteral("sessionWorkouts"), session.workouts},
                {QStringLiteral("sessionDuration"), session.durationSeconds},
                {QStringLiteral("sessionDateTime"), session.dateTime}
            };
        }
    }
    return {};
}

int SessionModel::count() const
{
    return m_sessions.size();
}

QVariantList SessionModel::getSessionsForDate(const QString &dateStr) const
{
    QVariantList results;
    for (const Session &session : m_sessions) {
        if (session.dateTime.startsWith(dateStr)) {
            results.append(QVariantMap{
                {QStringLiteral("sessionId"), session.id},
                {QStringLiteral("sessionPlanName"), session.planName},
                {QStringLiteral("sessionWorkouts"), session.workouts},
                {QStringLiteral("sessionDuration"), session.durationSeconds},
                {QStringLiteral("sessionDateTime"), session.dateTime}
            });
        }
    }
    return results;
}

QStringList SessionModel::getDatesWithSessions() const
{
    QSet<QString> dates;
    for (const Session &session : m_sessions)
        dates.insert(session.dateTime.left(10));
    return dates.values();
}
