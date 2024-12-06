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
        keyword = "left";
    } else if (moveRight == 1) {
        keyword = "right";
    } else if (moveUpRight == 1) {
        keyword = "rightup";
    } else if (moveUpLeft == 1) {
        keyword = "leftup";
    } else if (moveDown == 1) {
        keyword = "down";
    } else if (moveDownLeft == 1) {
        keyword = "leftdown";
    } else if (moveDownRight == 1) {
        keyword = "rightdown";
    } else if (moveUp == 1) {
        keyword = "up";
    }
    if (keyword !== "") {
        return returnValue("cgi-bin/ptzctrl.cgi?ptzcmd&" + keyword + "&" + ptSpeed + "&1");
    }
    if (zoomIn == 1) {
        keyword = "zoomin";
    } else if (zoomOut == 1) {
        keyword = "zoomout";
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