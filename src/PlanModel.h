#pragma once

#include <QAbstractListModel>
#include <QVariantList>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

struct Plan {
    int id;
    QString name;
    QVariantList workouts;
    QStringList reminderDays;
    QString reminderTime;
};

class PlanModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        PlanIdRole = Qt::UserRole + 1,
        PlanNameRole,
        PlanWorkoutsRole,
        ReminderDaysRole,
        ReminderTimeRole
    };

    explicit PlanModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int addPlan(const QString &name,
                            const QVariantList &workouts,
                            const QStringList &reminderDays,
                            const QString &reminderTime);
    Q_INVOKABLE void removePlan(int planId);
    Q_INVOKABLE void updatePlan(int planId,
                                const QString &name,
                                const QVariantList &workouts,
                                const QStringList &reminderDays,
                                const QString &reminderTime);
    Q_INVOKABLE QVariantList getPlanWorkouts(int planId) const;
    Q_INVOKABLE QVariantMap getPlan(int planId) const;

    int count() const;

Q_SIGNALS:
    void countChanged();

private:
    void initDatabase();
    void loadPlans();
    void savePlan(const Plan &plan);
    void updatePlanInDb(const Plan &plan);
    void deletePlanFromDb(int planId);

    QList<Plan> m_plans;
};
