function oscEvent(address, args) {
    script.log("OSC Message received " + address + ", " + args.length + " arguments");
}

function wsDataReceived(data) {
    script.log("Data received : " + data.length);
}

function valueBoolParameter(value, data) {
    if (local.values.getChild(value) == null) {
        local.values.addBoolParameter(value, "", data);
        local.values.getChild(value).setAttribute("readonly", true);
    } else {
        local.values.getChild(value).set(data);
    }
}

/* ************************************************************************* */
/* ***************** WEBSOCKET  MESSAGE RECEIVED *************************** */

/* ************************************************************************* */
function wsMessageReceived(message) {
// script.log("JUHHUU"+message);
    var obsObj = JSON.parse(message);
    var d = obsObj.d;

    //{requestId:, requestStatus:{code:100, result:1}, requestType:GetSceneItemEnabled, responseData:{sceneItemEnabled:0}}
    // if (d.requestType === "GetSceneItemEnabled") {
    //     key_name = "scene_item_" + d.eventData.sceneItemId + "_enabled";
    //     valueBoolParameter(key_name, d.responseData.sceneItemEnabled);
    // }
    // 15:54:16.561	OBS Websocket	Message received : {"d":{"eventData":{"sceneItemEnabled":false,"sceneItemId":20,"sceneName":"_ Notebook + Cam","sceneUuid":"9b69a2be-e7f9-4db7-a2be-54ceda5fe841"},"eventIntent":128,"eventType":"SceneItemEnableStateChanged"},"op":5}
    // //StreamStateChanged Event
    if (d.eventType === "SceneItemEnableStateChanged") {
        valueBoolParameterForSceneItem(d.eventData.sceneItemId, d.eventData.sceneItemEnabled);
    }


    if (d.requestType === "GetSceneItemList") {
        // script.log("xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        // script.log(message);
        // {"d":{"requestId":"updateSceneContainer_SUNDAY_PRE_STREAM (live_on, rs_on, rec_off, mute_on)","requestStatus":{"code":100,"result":true},"requestType":"GetSceneItemList","responseData":{"sceneItems":[{"inputKind":"image_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":1,"sceneItemIndex":0,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":0.0,"positionX":0.0,"positionY":-63.0,"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"sourceHeight":0.0,"sourceWidth":0.0,"width":0.0},"sourceName":"palm-trees-2301981_1920.jpg","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"af118ec0-a85f-4a3d-afb9-ca15feee1077"},{"inputKind":"ffmpeg_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":4,"sceneItemIndex":1,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":0.0,"positionX":0.0,"positionY":0.0,"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"sourceHeight":0.0,"sourceWidth":0.0,"width":0.0},"sourceName":"christian-piano-music-143489.mp3","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"66391b3a-4fff-474b-9412-f6f9c23105a6"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":3,"sceneItemIndex":2,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":58.3125,"positionX":959.0,"positionY":774.0,"rotation":0.0,"scaleX":0.18602195382118225,"scaleY":0.1875,"sourceHeight":311.0,"sourceWidth":7242.0,"width":1347.1710205078125},"sourceName":"prestream_text3","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"0313b12d-5fc4-4c4c-baea-c752c7a11ba5"},{"inputKind":"browser_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":5,"sceneItemIndex":3,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":387.0,"positionX":1221.0,"positionY":232.5,"rotation":0.0,"scaleX":0.645312488079071,"scaleY":0.6449999809265137,"sourceHeight":600.0,"sourceWidth":1920.0,"width":1239.0},"sourceName":"prestream_cntdwn","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"bbf2ed3c-dae9-4a69-9bfc-20ab62403f58"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":false,"sceneItemId":6,"sceneItemIndex":4,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":84.36363983154297,"positionX":1533.0,"positionY":303.45452880859375,"rotation":0.0,"scaleX":0.32896706461906433,"scaleY":0.3295454680919647,"sourceHeight":256.0,"sourceWidth":233.0,"width":76.64932250976563},"sourceName":"prestream_text2","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"444989cc-e2f8-415c-8542-6b72edbc9ff4"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":7,"sceneItemIndex":5,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":188.908203125,"positionX":713.0,"positionY":77.0,"rotation":0.0,"scaleX":0.6085312962532043,"scaleY":0.607421875,"sourceHeight":311.0,"sourceWidth":2270.0,"width":1381.3660888671875},"sourceName":"prestream_text4","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"8886eb5f-a73b-4c7a-812f-619c805bffe0"}]}},"op":7}
        var n = 0;
        if (d.requestId.startsWith("updateSceneContainer_")) {

            while (d.responseData['sceneItems'][n].sourceName != null) {
                var sceneItemId = d.responseData['sceneItems'][n].sceneItemId;
                var sceneItemEnabled = d.responseData['sceneItems'][n].sceneItemEnabled;
                valueBoolParameterForSceneItem(sceneItemId, sceneItemEnabled);
                n++;
            }
        }


    }


}

var ObsCeneItemVisibilityName = "SceneItemVisibility";

function valueBoolParameterForSceneItem(itemId, isPresent) {
    var itemName = "scene_item_" + itemId;
    c = local.values.getChild(ObsCeneItemVisibilityName);
    if (c === null) {
        c = local.values.addContainer(ObsCeneItemVisibilityName);
    }

    if (c.getChild(itemName) == null) {
        c.addBoolParameter(itemName, "", isPresent);
        c.getChild(itemName).setAttribute("readonly", true);
    } else {
        c.getChild(itemName).set(isPresent);
    }
}

/*
 This function will be called each time a value of this module has changed, meaning a parameter or trigger inside the "Values" panel of this module
 This function only exists because the script is in a module
*/
function moduleValueChanged(value) {
    if (value.name === "removeAllValues") {
        local.values.removeContainer(ObsCeneItemVisibilityName);
    }
}