#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QIcon>
#include <KLocalizedContext>
#include <KLocalizedString>

#ifndef Q_OS_ANDROID
#include <QApplication>
#include <QQuickStyle>
#include <KIconTheme>
#endif

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif
int main(int argc, char *argv[])
{
#ifndef Q_OS_ANDROID
    KIconTheme::initTheme();
    QApplication app(argc, argv);
#else
    QGuiApplication app(argc, argv);
#endif
    KLocalizedString::setApplicationDomain("tutorial");
    QGuiApplication::setOrganizationName(QStringLiteral("KDE"));
    QGuiApplication::setOrganizationDomain(QStringLiteral("kde.org"));
    QGuiApplication::setApplicationName(QStringLiteral("GymLogger"));
    QGuiApplication::setDesktopFileName(QStringLiteral("gymlogger"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("gymlogger")));

#ifndef Q_OS_ANDROID
    QApplication::setStyle(QStringLiteral("breeze"));
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
#endif

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("org.kde.tutorial", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
