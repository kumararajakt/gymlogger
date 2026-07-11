#include "ExerciseModel.h"

ExerciseModel::ExerciseModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int ExerciseModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_exercises.size();
}

QVariant ExerciseModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_exercises.size())
        return {};

    const Exercise &ex = m_exercises.at(index.row());

    switch (role) {
    case ExerciseIdRole:
        return ex.exerciseId;
    case NameRole:
        return ex.name;
    case GifUrlRole:
        return ex.gifUrl;
    case BodyPartsRole:
        return ex.bodyParts;
    case TargetMusclesRole:
        return ex.targetMuscles;
    case SecondaryMusclesRole:
        return ex.secondaryMuscles;
    case EquipmentsRole:
        return ex.equipments;
    case InstructionsRole:
        return ex.instructions;
    default:
        return {};
    }
}

QHash<int, QByteArray> ExerciseModel::roleNames() const
{
    return {
        {ExerciseIdRole, "exerciseId"},
        {NameRole, "name"},
        {GifUrlRole, "gifUrl"},
        {BodyPartsRole, "bodyParts"},
        {TargetMusclesRole, "targetMuscles"},
        {SecondaryMusclesRole, "secondaryMuscles"},
        {EquipmentsRole, "equipments"},
        {InstructionsRole, "instructions"}
    };
}

void ExerciseModel::addExercise(const QVariantMap &exercise)
{
    int row = m_exercises.size();
    beginInsertRows(QModelIndex(), row, row);
    m_exercises.append({
        exercise.value(QStringLiteral("exerciseId")).toString(),
        exercise.value(QStringLiteral("name")).toString(),
        exercise.value(QStringLiteral("gifUrl")).toString(),
        exercise.value(QStringLiteral("bodyParts")).toString(),
        exercise.value(QStringLiteral("targetMuscles")).toString(),
        exercise.value(QStringLiteral("secondaryMuscles")).toString(),
        exercise.value(QStringLiteral("equipments")).toString(),
        exercise.value(QStringLiteral("instructions")).toString()
    });
    endInsertRows();
    Q_EMIT countChanged();
}

void ExerciseModel::clear()
{
    if (m_exercises.isEmpty())
        return;
    beginResetModel();
    m_exercises.clear();
    endResetModel();
    Q_EMIT countChanged();
}

bool ExerciseModel::contains(const QString &exerciseId) const
{
    for (const Exercise &ex : m_exercises) {
        if (ex.exerciseId == exerciseId)
            return true;
    }
    return false;
}

QVariantMap ExerciseModel::get(int index) const
{
    if (index < 0 || index >= m_exercises.size())
        return {};

    const Exercise &ex = m_exercises.at(index);
    return {
        {QStringLiteral("exerciseId"), ex.exerciseId},
        {QStringLiteral("name"), ex.name},
        {QStringLiteral("gifUrl"), ex.gifUrl},
        {QStringLiteral("bodyParts"), ex.bodyParts},
        {QStringLiteral("targetMuscles"), ex.targetMuscles},
        {QStringLiteral("secondaryMuscles"), ex.secondaryMuscles},
        {QStringLiteral("equipments"), ex.equipments},
        {QStringLiteral("instructions"), ex.instructions}
    };
}

int ExerciseModel::count() const
{
    return m_exercises.size();
}
