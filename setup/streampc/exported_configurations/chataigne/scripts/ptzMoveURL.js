function filter(input, min, max) {
// script.log(input);
    var moveLeft = input[1];
    var moveRight = input[2];
    var moveUpRight = input[3];
    var moveUpLeft = input[4];
    var moveDown = input[5];
    var moveDownLeft = input[6];
    var moveDownRight = input[7];
    var moveUp = input[8];
    var zoomIn = input[9];
    var zoomOut = input[10];
    var ptSpeed = input[11];
    var zoomSpeed = input[12];

    var keyword = "";

    if (moveLeft == 1) {
        keyword = "LEFT";
    } else if (moveRight == 1) {
        keyword = "RIGHT";
    } else if (moveUpRight == 1) {
        keyword = "RIGHTUP";
    } else if (moveUpLeft == 1) {
        keyword = "LEFTUP";
    } else if (moveDown == 1) {
        keyword = "DOWN";
    } else if (moveDownLeft == 1) {
        keyword = "LEFTDOWN";
    } else if (moveDownRight == 1) {
        keyword = "RIGHTDOWN";
    } else if (moveUp == 1) {
        keyword = "UP";
    }
    if (keyword !== "") {
        return returnValue("cgi-bin/ptzctrl.cgi?ptzcmd&" + keyword + "&" + ptSpeed + "&1");
    }
    if (zoomIn == 1) {
        keyword = "ZOOMIN";
    } else if (zoomOut == 1) {
        keyword = "ZOOMOUT";
    }

    if (keyword !== "") {
        return returnValue("cgi-bin/ptzctrl.cgi?ptzcmd&" + keyword + "&" + zoomSpeed + "&1");
    }
    return returnValue("");
}

function returnValue(url) {
    script.log("CAMERA URL:" + url);
    return [url, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
}