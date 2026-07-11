#pragma once

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>

struct Exercise {
    QString exerciseId;
    QString name;
    QString gifUrl;
    QString bodyParts;
    QString targetMuscles;
    QString secondaryMuscles;
    QString equipments;
    QString instructions;
};

class ExerciseModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        ExerciseIdRole = Qt::UserRole + 1,
        NameRole,
        GifUrlRole,
        BodyPartsRole,
        TargetMusclesRole,
        SecondaryMusclesRole,
        EquipmentsRole,
        InstructionsRole
    };

    explicit ExerciseModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addExercise(const QVariantMap &exercise);
    Q_INVOKABLE void clear();
    Q_INVOKABLE bool contains(const QString &exerciseId) const;
    Q_INVOKABLE QVariantMap get(int index) const;

    int count() const;

Q_SIGNALS:
    void countChanged();

private:
    QList<Exercise> m_exercises;
};
