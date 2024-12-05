function filter(inputValue, min, max) {
    var horizontal = inputValue[1];
    var vertical = inputValue[2];
    var zoom = inputValue[3];

    var horizontalSpeed = Math.round(Math.abs(horizontal));
    horizontalSpeed = horizontalSpeed > 26 ? horizontalSpeed - 26 : 0;

    var verticalspeed = Math.round(Math.abs(vertical));
    verticalspeed = verticalspeed > 26 ? verticalspeed - 26 : 0;

    var zoomSpeed = Math.round(Math.abs(zoom));
    zoomSpeed = zoomSpeed > 26 ? zoomSpeed - 26 : 0;


    if (horizontalSpeed !== 0) {
        return ["cgi-bin/ptzctrl.cgi?ptzcmd&" + (horizontal < 0 ? "LEFT" : "RIGHT") + "&" + horizontalSpeed + "&1", 0, 0, 0];
    }
    if (verticalspeed !== 0) {
        return ["cgi-bin/ptzctrl.cgi?ptzcmd&" + (vertical < 0 ? "UP" : "DOWN") + "&" + verticalspeed + "&1", 0, 0, 0];
    }
    if (zoomSpeed !== 0) {
        return ["cgi-bin/ptzctrl.cgi?ptzcmd&" + (zoom < 0 ? "ZOOMIN" : "ZOOMOUT") + "&" + zoomSpeed + "&1", 0, 0, 0];
    }

    return inputValue;
}