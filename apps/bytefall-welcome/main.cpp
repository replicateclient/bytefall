#include <QGuiApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QRegularExpression>
#include <QStringList>
#include <QUrl>

class Launcher : public QObject
{
    Q_OBJECT

public:
    using QObject::QObject;

    Q_INVOKABLE void launch(const QStringList &command)
    {
        if (command.isEmpty()) {
            return;
        }
        QProcess::startDetached(command.first(), command.mid(1));
    }

    Q_INVOKABLE bool launchInstaller()
    {
        const QList<QStringList> attempts = {
            { QStringLiteral("/usr/bin/bytefall-install-launcher") },
            { QStringLiteral("/usr/bin/bash"), QStringLiteral("/usr/local/bin/bytefall-installer") },
            { QStringLiteral("/usr/bin/konsole"), QStringLiteral("--noclose"), QStringLiteral("-e"),
              QStringLiteral("/usr/bin/bash"), QStringLiteral("/usr/local/bin/bytefall-installer") }
        };

        for (const QStringList &attempt : attempts) {
            if (attempt.isEmpty()) {
                continue;
            }
            if (QProcess::startDetached(attempt.first(), attempt.mid(1))) {
                return true;
            }
        }
        return false;
    }

    Q_INVOKABLE bool isLiveSession() const
    {
        return QFile::exists(QStringLiteral("/run/archiso/bootmnt")) ||
               QFile::exists(QStringLiteral("/run/archiso/airootfs"));
    }

    Q_INVOKABLE bool autostartEnabled() const
    {
        QFile overrideFile(autostartOverridePath());
        if (!overrideFile.exists()) {
            return true;
        }
        if (!overrideFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return true;
        }
        return !QString::fromUtf8(overrideFile.readAll()).contains(QStringLiteral("Hidden=true"));
    }

    Q_INVOKABLE void setAutostartEnabled(bool enabled)
    {
        const QString path = autostartOverridePath();
        if (enabled) {
            QFile::remove(path);
            return;
        }

        const QFileInfo info(path);
        QDir().mkpath(info.path());

        QFile overrideFile(path);
        if (!overrideFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
            return;
        }

        const QByteArray contents =
            "[Desktop Entry]\n"
            "Type=Application\n"
            "Name=Bytefall Welcome\n"
            "Exec=bytefall-welcome\n"
            "Hidden=true\n";
        overrideFile.write(contents);
    }

    Q_INVOKABLE QString gpuSelection() const
    {
        QFile selectionFile(gpuSelectionPath());
        if (!selectionFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return QString();
        }

        const QString value = QString::fromUtf8(selectionFile.readAll()).trimmed().toLower();
        if (value == QStringLiteral("auto") ||
            value == QStringLiteral("amd") ||
            value == QStringLiteral("nvidia") ||
            value == QStringLiteral("none")) {
            return value;
        }
        return QString();
    }

    Q_INVOKABLE void setGpuSelection(const QString &selection)
    {
        const QString normalized = selection.trimmed().toLower();
        if (normalized != QStringLiteral("auto") &&
            normalized != QStringLiteral("amd") &&
            normalized != QStringLiteral("nvidia") &&
            normalized != QStringLiteral("none")) {
            return;
        }

        const QString path = gpuSelectionPath();
        const QFileInfo info(path);
        QDir().mkpath(info.path());

        QFile selectionFile(path);
        if (!selectionFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
            return;
        }
        selectionFile.write(normalized.toUtf8());
        selectionFile.write("\n");
    }

    Q_INVOKABLE QString recommendedGpuSelection() const
    {
        const auto info = detectGpuInfo();
        return info.recommendedSelection;
    }

    Q_INVOKABLE QString detectedGpuSummary() const
    {
        const auto info = detectGpuInfo();
        return info.summary;
    }

private:
    struct GpuInfo
    {
        QString recommendedSelection = QStringLiteral("none");
        QString summary = QStringLiteral("No discrete AMD or NVIDIA GPU was detected in this live session.");
    };

    static QString autostartOverridePath()
    {
        return QDir::homePath() + QStringLiteral("/.config/autostart/bytefall-welcome.desktop");
    }

    static QString gpuSelectionPath()
    {
        return QDir::homePath() + QStringLiteral("/.config/bytefall/gpu-selection.conf");
    }

    static GpuInfo detectGpuInfo()
    {
        GpuInfo info;
        QProcess process;
        process.start(QStringLiteral("lspci"), { QStringLiteral("-nn") });
        if (!process.waitForFinished(3000) || process.exitStatus() != QProcess::NormalExit) {
            info.summary = QStringLiteral("GPU detection is unavailable right now. Auto will fall back to the safest match it can find.");
            return info;
        }

        const QString output = QString::fromUtf8(process.readAllStandardOutput());
        const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
        QStringList gpuLines;
        bool hasNvidia = false;
        bool hasAmd = false;

        for (const QString &rawLine : lines) {
            const QString line = rawLine.trimmed();
            if (!(line.contains(QStringLiteral("VGA compatible controller"), Qt::CaseInsensitive) ||
                  line.contains(QStringLiteral("3D controller"), Qt::CaseInsensitive) ||
                  line.contains(QStringLiteral("Display controller"), Qt::CaseInsensitive))) {
                continue;
            }

            gpuLines.append(line);
            const QString lower = line.toLower();
            if (lower.contains(QStringLiteral("nvidia"))) {
                hasNvidia = true;
            }
            if (lower.contains(QStringLiteral("advanced micro devices")) ||
                lower.contains(QStringLiteral(" amd/ati")) ||
                lower.contains(QStringLiteral(" amd ")) ||
                lower.contains(QStringLiteral("ati technologies"))) {
                hasAmd = true;
            }
        }

        if (hasNvidia) {
            info.recommendedSelection = QStringLiteral("nvidia");
        } else if (hasAmd) {
            info.recommendedSelection = QStringLiteral("amd");
        }

        if (gpuLines.isEmpty()) {
            return info;
        }

        if (gpuLines.size() == 1) {
            info.summary = gpuLines.first();
        } else {
            info.summary = gpuLines.join(QStringLiteral("\n"));
        }

        return info;
    }
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Bytefall Welcome");
    app.setDesktopFileName("bytefall-welcome");

    Launcher launcher;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Launcher", &launcher);
    engine.load(QUrl(QStringLiteral("file:///usr/share/bytefall/welcome/Main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return 1;
    }
    return app.exec();
}

#include "main.moc"
