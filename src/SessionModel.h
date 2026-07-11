#pragma once

#include <QAbstractListModel>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

struct Session {
    int id;
    QString planName;
    QVariantList workouts;
    int durationSeconds;
    QString dateTime;
};

class SessionModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        SessionIdRole = Qt::UserRole + 1,
        SessionPlanNameRole,
        SessionWorkoutsRole,
        SessionDurationRole,
        SessionDateTimeRole
    };

    explicit SessionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int addSession(const QString &planName,
                               const QVariantList &workouts,
                               int durationSeconds);
    Q_INVOKABLE void removeSession(int sessionId);
    Q_INVOKABLE QVariantMap getSession(int sessionId) const;
    Q_INVOKABLE QVariantList getSessionsForDate(const QString &dateStr) const;
    Q_INVOKABLE QStringList getDatesWithSessions() const;

    int count() const;

Q_SIGNALS:
    void countChanged();

private:
    void initDatabase();
    void loadSessions();
    void saveSession(const Session &session);
    void deleteSessionFromDb(int sessionId);

    QList<Session> m_sessions;
};
