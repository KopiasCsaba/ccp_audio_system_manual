/* ************************************************************************* */
/* ***************** WEBSOCKET  MESSAGE RECEIVED *************************** */

/* ************************************************************************* */
function wsMessageReceived(message) {
// script.log("JUHHUU"+message);
    var obsObj = JSON.parse(message);
    var d = obsObj.d;

//GetCurrentProgramScene
    if (d.requestType === "GetCurrentProgramScene") {
        updateTags(d.responseData.currentProgramSceneName);
    }
//CurrentProgramSceneChanged Event
    if (d.eventType === "CurrentProgramSceneChanged") {
        updateTags(d.eventData.sceneName);
    }
}


function updateTags(sceneName) {

    clearFlags();
    var beginning = sceneName.indexOf("(");
    var end = sceneName.indexOf(")");
    if (end == -1 || beginning == -1) {
        return;
    }

    var tagPart = sceneName.substring(beginning + 1, end);


    tagPart = tagPart.replace(" ", "");
    var tags = tagPart.split(",");
    script.log("------------");
    script.log(beginning);
    script.log(end);
    script.log(tags.length);

    for (var i = 0; i < tags.length; i++) {

        valueBoolParameterForTag(tags[i], true);
    }
}


function valueBoolParameterForTag(tagName, isPresent) {
    c = local.values.getChild("SceneNameTags");
    if (c === null) {
        c = local.values.addContainer("SceneNameTags");
    }

    if (c.getChild(tagName) == null) {
        c.addBoolParameter(tagName, "", isPresent);
        c.getChild(tagName).setAttribute("readonly", true);
    } else {
        c.getChild(tagName).set(isPresent);
    }
}

function clearFlags() {
    c = local.values.getChild("SceneNameTags");
    if (c === null) {
     return;
    }
    var tagControls = c.getControllables();
    for(var i=0;i<tagControls.length;i++) {
        tagControls[i].set(false);
    }

    // script.log(JSON.stringify(c.getControllables(),null," "));

}

/*
 This function will be called each time a value of this module has changed, meaning a parameter or trigger inside the "Values" panel of this module
 This function only exists because the script is in a module
*/
function moduleValueChanged(value) {
    if (value.name === "removeAllValues") {
        local.values.removeContainer("SceneNameTags");
    }
}