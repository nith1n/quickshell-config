// Fillet.qml
import QtQuick
import "../helpers"

Canvas {
    id: root
    property string corner: "top-left" // "top-left", "top-right", "bottom-left", "bottom-right"
    property color color: Theme.barBg
    property real radius: Theme.filletRadius

    width: radius
    height: radius

    onRadiusChanged: requestPaint()
    onColorChanged: requestPaint()
    onCornerChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = root.color;
        ctx.beginPath();

        var r = root.radius;

        if (root.corner === "top-left") {
            ctx.moveTo(0, r);
            ctx.lineTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.arc(r, r, r, -Math.PI / 2, Math.PI, true);
        } else if (root.corner === "top-right") {
            ctx.moveTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.lineTo(r, r);
            ctx.arc(0, r, r, 0, -Math.PI / 2, true);
        } else if (root.corner === "bottom-left") {
            ctx.moveTo(0, 0);
            ctx.lineTo(0, r);
            ctx.lineTo(r, r);
            ctx.arc(r, 0, r, Math.PI / 2, Math.PI, false);
        } else if (root.corner === "bottom-right") {
            ctx.moveTo(r, 0);
            ctx.lineTo(r, r);
            ctx.lineTo(0, r);
            ctx.arc(0, 0, r, Math.PI / 2, 0, true);
        }

        ctx.closePath();
        ctx.fill();
    }
}
