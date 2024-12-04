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
        key_name = "scene_item_" + d.eventData.sceneItemId + "_enabled";
        valueBoolParameter(key_name, d.eventData.sceneItemEnabled);
    }


    if (d.requestType === "GetSceneItemList") {
        // script.log("xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        // script.log(message);
        // {"d":{"requestId":"updateSceneContainer_SUNDAY_PRE_STREAM (live_on, rs_on, rec_off, mute_on)","requestStatus":{"code":100,"result":true},"requestType":"GetSceneItemList","responseData":{"sceneItems":[{"inputKind":"image_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":1,"sceneItemIndex":0,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":0.0,"positionX":0.0,"positionY":-63.0,"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"sourceHeight":0.0,"sourceWidth":0.0,"width":0.0},"sourceName":"palm-trees-2301981_1920.jpg","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"af118ec0-a85f-4a3d-afb9-ca15feee1077"},{"inputKind":"ffmpeg_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":4,"sceneItemIndex":1,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":0.0,"positionX":0.0,"positionY":0.0,"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"sourceHeight":0.0,"sourceWidth":0.0,"width":0.0},"sourceName":"christian-piano-music-143489.mp3","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"66391b3a-4fff-474b-9412-f6f9c23105a6"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":3,"sceneItemIndex":2,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":58.3125,"positionX":959.0,"positionY":774.0,"rotation":0.0,"scaleX":0.18602195382118225,"scaleY":0.1875,"sourceHeight":311.0,"sourceWidth":7242.0,"width":1347.1710205078125},"sourceName":"prestream_text3","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"0313b12d-5fc4-4c4c-baea-c752c7a11ba5"},{"inputKind":"browser_source","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":5,"sceneItemIndex":3,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":387.0,"positionX":1221.0,"positionY":232.5,"rotation":0.0,"scaleX":0.645312488079071,"scaleY":0.6449999809265137,"sourceHeight":600.0,"sourceWidth":1920.0,"width":1239.0},"sourceName":"prestream_cntdwn","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"bbf2ed3c-dae9-4a69-9bfc-20ab62403f58"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":false,"sceneItemId":6,"sceneItemIndex":4,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":84.36363983154297,"positionX":1533.0,"positionY":303.45452880859375,"rotation":0.0,"scaleX":0.32896706461906433,"scaleY":0.3295454680919647,"sourceHeight":256.0,"sourceWidth":233.0,"width":76.64932250976563},"sourceName":"prestream_text2","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"444989cc-e2f8-415c-8542-6b72edbc9ff4"},{"inputKind":"text_ft2_source_v2","isGroup":null,"sceneItemBlendMode":"OBS_BLEND_NORMAL","sceneItemEnabled":true,"sceneItemId":7,"sceneItemIndex":5,"sceneItemLocked":false,"sceneItemTransform":{"alignment":5,"boundsAlignment":0,"boundsHeight":0.0,"boundsType":"OBS_BOUNDS_NONE","boundsWidth":0.0,"cropBottom":0,"cropLeft":0,"cropRight":0,"cropToBounds":false,"cropTop":0,"height":188.908203125,"positionX":713.0,"positionY":77.0,"rotation":0.0,"scaleX":0.6085312962532043,"scaleY":0.607421875,"sourceHeight":311.0,"sourceWidth":2270.0,"width":1381.3660888671875},"sourceName":"prestream_text4","sourceType":"OBS_SOURCE_TYPE_INPUT","sourceUuid":"8886eb5f-a73b-4c7a-812f-619c805bffe0"}]}},"op":7}
        var n = 0;
        if (d.requestId.startsWith("updateSceneContainer_")) {
            script.log("XXXXXXXXXXXXXXX"+message);
            var scene = d.requestId.replace("updateSceneContainer_", "");
            while (d.responseData['sceneItems'][n].sourceName != null) {
                var sceneItemId = d.responseData['sceneItems'][n].sceneItemId;
                var sourceName = d.responseData['sceneItems'][n].sourceName;
                var sceneItemEnabled = d.responseData['sceneItems'][n].sceneItemEnabled;

                key_name = "scene_item_" + sceneItemId + "_enabled";
                script.log(" KEY: "+key_name+" Enabled: "+(sceneItemEnabled?"T":"F"));
                valueBoolParameter(key_name, sceneItemEnabled);

                n++;
            }
        }


    }


    // /* ************************* CONNECTION ******************************** */
    // var obsObj = JSON.parse(message);
    // var d = obsObj.d;
    //
    // if (obsObj.op == 0 && d.authentication != null) {
    //     var newEventSub = "1" + (local.parameters.eventSub.sceneItemTransformChanged.get() ? "1" : "0") + (local.parameters.eventSub.inputShowStateChanged.get() ? "1" : "0") + (local.parameters.eventSub.inputActiveStateChanged.get() ? "1" : "0") + (local.parameters.eventSub.inputVolumeMeters.get() ? "1" : "0") + "00000" + (local.parameters.eventSub.ui.get() ? "1" : "0") + (local.parameters.eventSub.vendors.get() ? "1" : "0") + (local.parameters.eventSub.mediaInputs.get() ? "1" : "0") + (local.parameters.eventSub.sceneItems.get() ? "1" : "0") + (local.parameters.eventSub.outputs.get() ? "1" : "0") + (local.parameters.eventSub.filters.get() ? "1" : "0") + (local.parameters.eventSub.transitions.get() ? "1" : "0") + (local.parameters.eventSub.inputs.get() ? "1" : "0") + (local.parameters.eventSub.scenes.get() ? "1" : "0") + (local.parameters.eventSub.config.get() ? "1" : "0") + (local.parameters.eventSub.general.get() ? "1" : "0");
    //     var mdp = local.parameters.password.get() + d.authentication.salt;
    //     var Encode1 = util.toBase64(parseHex(util.encodeSHA256(mdp)));
    //     var Encode2 = util.toBase64(parseHex(util.encodeSHA256(Encode1 + d.authentication.challenge)));
    //     local.send('{"d":{"authentication": "' + Encode2 + '", "eventSubscriptions": ' + toDecimal(newEventSub) + ', "rpcVersion": 1}, "op": 1}');
    // }
    // else if (obsObj.op == 0) {
    //     local.send('{"op": 1,"d": {"rpcVersion": 1,"authentication": "Chataigne","eventSubscriptions": ' + toDecimal(newEventSub) + '} }');
    // }
    // else if (obsObj.op == 2) {
    //     //TODO
    //     GetStudioModeEnabled(7);
    //     removeAllValues();
    //     GetSceneList(7);
    //     GetInputList(7);
    //     GetCurrentProgramScene(7);
    //
    // }
    // /* ************ CHANGED VALUES WITH MESSAGE RECEIVED ******************** */
    // //GetSceneCollectionList
    // if (d.requestType == "GetSceneCollectionList") {
    //     var n = 0;
    //     local.values.addContainer("Collections");
    //     valueStringParameter("CurrentCollection", d.responseData.currentSceneCollectionName);
    //     while (d.responseData.sceneCollections[n] != null) {
    //         var collection = d.responseData.sceneCollections[n];
    //         local.values.getChild("Collections").addStringParameter("Collection" + n, "", collection);
    //         local.values.getChild("Collections").getChild("Collection" + n).setAttribute("readonly", true);
    //         n++;
    //     }
    // }
    //
    // if (d.requestType == "GetStudioModeEnabled") {
    //     local.values.controlsStatus.studioModeStatus.set(d.responseData.studioModeEnabled);
    //     if (d.responseData.studioModeEnabled) {
    //         GetCurrentPreviewScene(7);
    //     }
    // }
    // //GetSceneList
    // if (d.requestType == "GetSceneList") {
    //     var n = 0;
    //     if (local.values.getChild("Scenes") == null) {
    //         local.values.addContainer("Scenes");
    //         EnumScenes = local.values.getChild("Scenes").addEnumParameter("Slct Scene", "The scene selected for controller");
    //         EnumItems = local.values.getChild("Scenes").addEnumParameter("Slct Item", "The item selected for controller");
    //     }
    //
    //     while (d.responseData['scenes'][n].sceneIndex != null) {
    //         var index = d.responseData['scenes'][n].sceneIndex;
    //         var scene = d.responseData['scenes'][n].sceneName;
    //         if (local.values.getChild("Scenes").getChild(scene) == null) {
    //             local.values.getChild("Scenes").addContainer(scene);
    //             local.values.getChild("Scenes").getChild(scene).addStringParameter("sceneIndex", "", index);
    //             local.values.getChild("Scenes").getChild(scene).getChild("sceneIndex").setAttribute("readonly", true);
    //             local.values.getChild("Scenes").getChild(scene).addStringParameter("sceneName", "", scene);
    //             local.values.getChild("Scenes").getChild(scene).getChild("sceneName").setAttribute("readonly", true);
    //         }
    //         local.values.getChild("Scenes").getChild(scene).getChild("sceneIndex").set(index);
    //         local.values.getChild("Scenes").getChild(scene).getChild("sceneName").set(scene);
    //         GetSceneItemList("updateSceneContainer_" + scene, scene);
    //         OBSSave[scene] = {};
    //         //local.values.getChild("Scenes").getChild("Slct Scene").addOption(scene,index);
    //         EnumScenes.addOption(scene, scene);
    //         n++;
    //     }
    //     valueStringParameter("CurrentScene", d.responseData.currentProgramSceneName);
    //     if (d.responseData.currentPreviewSceneName != null) {
    //         EnumScenes.set(d.responseData.currentPreviewSceneName);
    //         GetSceneItemList("active_items_" + d.responseData.currentPreviewSceneName, d.responseData.currentPreviewSceneName);
    //     } else {
    //         EnumScenes.set(d.responseData.currentProgramSceneName);
    //         GetSceneItemList("active_items_" + d.responseData.currentProgramSceneName, d.responseData.currentProgramSceneName);
    //     }
    // }
    //
    // //GetInputList
    // if (d.requestType == "GetInputList") {
    //     var n = 0;
    //     if (local.values.getChild("Inputs") == null) {
    //         local.values.addContainer("Inputs");
    //     }
    //     while (d.responseData['inputs'][n].inputKind != null) {
    //         var inputKind = d.responseData['inputs'][n].inputKind;
    //         var inputName = d.responseData['inputs'][n].inputName;
    //         if (local.values.getChild("Inputs").getChild(inputName) == null) {
    //             local.values.getChild("Inputs").addContainer(inputName);
    //             local.values.getChild("Inputs").getChild(inputName).addStringParameter("inputName", "", inputName);
    //             local.values.getChild("Inputs").getChild(inputName).getChild("inputName").setAttribute("readonly", true);
    //             local.values.getChild("Inputs").getChild(inputName).addStringParameter("inputKind", "", inputKind);
    //             local.values.getChild("Inputs").getChild(inputName).getChild("inputKind").setAttribute("readonly", true);
    //         }
    //         local.values.getChild("Inputs").getChild(inputName).getChild("inputName").set(inputName);
    //         local.values.getChild("Inputs").getChild(inputName).getChild("inputKind").set(inputKind);
    //         n++;
    //     }
    // }
    //
    // //GetCurrentProgramScene
    // if (d.requestType == "GetCurrentProgramScene") {
    //     valueStringParameter("CurrentScene", d.responseData.currentProgramSceneName);
    //     if (!local.values.controlsStatus.studioModeStatus.get()) {
    //         EnumScenes.set(d.responseData.currentProgramSceneName);
    //         GetSceneItemList("active_items_" + d.responseData.currentProgramSceneName, d.responseData.currentProgramSceneName);
    //     }
    // }
    //
    // //SetCurrentProgramScene
    // if (d.requestType == "SetCurrentProgramScene") {
    //     valueStringParameter("CurrentScene", tempo);
    // }
    //
    // //GetGroupList
    // if (d.requestType == "GetGroupList") {
    //     var n = 0;
    //     local.values.addContainer("Groups");
    //     while (d.responseData.groups[n] != null) {
    //         var group = d.responseData.groups[n];
    //         local.values.getChild("Groups").addStringParameter("NameGroup" + n, "", group);
    //         local.values.getChild("Groups").getChild("NameGroup" + n).setAttribute("readonly", true);
    //         n++;
    //     }
    // }
    //
    // //GetSceneItemList
    // if (d.requestType == "GetSceneItemList") {
    //     var n = 0;
    //     if (d.requestId.startsWith("updateSceneContainer_")) {
    //         var scene = d.requestId.replace("updateSceneContainer_", "");
    //         while (d.responseData['sceneItems'][n].sourceName != null) {
    //             var sceneItemId = d.responseData['sceneItems'][n].sceneItemId;
    //             var sourceName = d.responseData['sceneItems'][n].sourceName;
    //             local.values.getChild("Scenes").getChild(scene).addContainer(sourceName);
    //             if (local.values.getChild("Scenes").getChild(scene).getChild(sourceName).getChild("IndexItem") == null) {
    //                 local.values.getChild("Scenes").getChild(scene).getChild(sourceName).addStringParameter("IndexItem", "", sceneItemId);
    //                 local.values.getChild("Scenes").getChild(scene).getChild(sourceName).getChild("IndexItem").setAttribute("readonly", true);
    //             }
    //             else {
    //                 local.values.getChild("Scenes").getChild(scene).getChild(sourceName).getChild("IndexItem").set(sceneItemId);
    //             }
    //             OBSSave[scene][sourceName] = {};
    //             OBSSave[scene][sourceName]['sceneItemId'] = sceneItemId;
    //             n++;
    //         }
    //     }
    //
    //     //Complete EnumScenes and EnumItems menu on scene change
    //     if (d.requestId.startsWith("active_items_")) {
    //         EnumItems.removeOptions();
    //         if (d.responseData['sceneItems'][0]) {
    //             var n = 0;
    //             while (d.responseData['sceneItems'][n].sourceName != null) {
    //                 var sceneItemId = d.responseData['sceneItems'][n].sceneItemId;
    //                 var sourceName = d.responseData['sceneItems'][n].sourceName;
    //                 EnumItems.addOption(sourceName, sceneItemId);
    //                 n++;
    //             }
    //             EnumItems.setPrevious(true);
    //             GetSceneItemTransform('active_item_parameter', EnumScenes.get(), EnumItems.get());
    //         }
    //     }
    //
    // }
    //
    // //GetSceneItemTransform get transform parameters for the active item
    // if (d.requestType == "GetSceneItemTransform") {
    //     if (d.requestId.startsWith("active_item_parameter")) {
    //         local.values.getChild("Active Item Transform").positionX.set(d.responseData.sceneItemTransform.positionX);
    //         local.values.getChild("Active Item Transform").positionY.set(d.responseData.sceneItemTransform.positionY);
    //         local.values.getChild("Active Item Transform").getChild("Zoom").set(d.responseData.sceneItemTransform.scaleX);
    //         local.values.getChild("Active Item Transform").rotation.set(d.responseData.sceneItemTransform.rotation);
    //         local.values.getChild("Active Item Transform").cropBottom.set(d.responseData.sceneItemTransform.cropBottom);
    //         local.values.getChild("Active Item Transform").cropLeft.set(d.responseData.sceneItemTransform.cropLeft);
    //         local.values.getChild("Active Item Transform").cropRight.set(d.responseData.sceneItemTransform.cropRight);
    //         local.values.getChild("Active Item Transform").cropTop.set(d.responseData.sceneItemTransform.cropTop);
    //
    //     }
    // }
    //
    // //StreamStateChanged Event
    // if (d.eventType == "StreamStateChanged") {
    //     valueBoolContainerParameter("Stream", "outputActive", d.eventData.outputActive);
    //     valueStringContainerParameter("Stream", "outputState", d.eventData.outputState);
    // }
    // //RecordStateChanged Event
    // if (d.eventType == "RecordStateChanged") {
    //     valueBoolContainerParameter("Record", "outputActive", d.eventData.outputActive);
    //     valueStringContainerParameter("Record", "outputState", d.eventData.outputState);
    //     valueStringContainerParameter("Record", "outputPath", d.eventData.outputPath);
    // }
    // //CurrentProgramSceneChanged Event
    // if (d.eventType == "CurrentProgramSceneChanged") {
    //     if (!local.values.controlsStatus.studioModeStatus.get()) {
    //         EnumScenes.set(d.eventData.sceneName);
    //         GetSceneItemList("active_items_" + d.eventData.sceneName, d.eventData.sceneName);
    //     }
    //     valueStringParameter("CurrentScene", d.eventData.sceneName);
    // }
    // //StudioModeStateChanged Event
    // if (d.eventType == "StudioModeStateChanged") {
    //     local.values.controlsStatus.studioModeStatus.set(d.eventData.studioModeEnabled);
    //     if (!d.eventData.studioModeEnabled) {
    //         GetCurrentProgramScene(7);
    //     }
    // }
    // //CurrentPreviewSceneChanged Event (need for studio mode)
    // if (d.eventType == "CurrentPreviewSceneChanged") {
    //     EnumScenes.set(d.eventData.sceneName);
    //     GetSceneItemList("active_items_" + d.eventData.sceneName, d.eventData.sceneName);
    // }
    //
    // //InputMuteStateChanged
    // if (d.eventType == "InputMuteStateChanged") {
    //     valueBoolContainerParameter("Audio Input", d.eventData.inputName, d.eventData.inputMuted);
    // }
    //
    // //SceneItemTransformChanged
    // if (d.eventType == "SceneItemTransformChanged") {
    //     if (d.eventData.sceneName == EnumScenes.get() && d.eventData.sceneItemId == local.values.getChild("Scenes").getChild(EnumScenes.get()).getChild(EnumItems.getKey()).getChild("IndexItem").get()) {
    //         local.values.getChild("Active Item Transform").positionX.set(d.eventData.sceneItemTransform.positionX);
    //         local.values.getChild("Active Item Transform").positionY.set(d.eventData.sceneItemTransform.positionY);
    //         local.values.getChild("Active Item Transform").getChild("Zoom").set(d.eventData.sceneItemTransform.scaleX);
    //         local.values.getChild("Active Item Transform").rotation.set(d.eventData.sceneItemTransform.rotation);
    //         local.values.getChild("Active Item Transform").cropBottom.set(d.eventData.sceneItemTransform.cropBottom);
    //         local.values.getChild("Active Item Transform").cropLeft.set(d.eventData.sceneItemTransform.cropLeft);
    //         local.values.getChild("Active Item Transform").cropRight.set(d.eventData.sceneItemTransform.cropRight);
    //         local.values.getChild("Active Item Transform").cropTop.set(d.eventData.sceneItemTransform.cropTop);
    //     }
    // }
    //
    // if (d.eventType == "SceneItemSelected") {
    //     var options = EnumItems.getAllOptions();
    //     var i = 0;
    //     for (i = 0; i < options.length; i++) {
    //         if (d.eventData.sceneItemId == options[i].value) {
    //             EnumItems.set(options[i].key);
    //             GetSceneItemTransform('active_item_parameter', d.eventData.sceneName, d.eventData.sceneItemId);
    //         }
    //     }
    // }
    //
    // if (d.eventType == "SceneItemCreated") {
    //     EnumItems.addOption(d.eventData.sourceName, d.eventData.sceneItemId);
    //     local.values.getChild("Scenes").getChild(d.eventData.sceneName).addContainer(d.eventData.sourceName);
    //     local.values.getChild("Scenes").getChild(d.eventData.sceneName).getChild(d.eventData.sourceName).addStringParameter("IndexItem", "", d.eventData.sceneItemId);
    //     local.values.getChild("Scenes").getChild(d.eventData.sceneName).getChild(d.eventData.sourceName).getChild("IndexItem").setAttribute("readonly", true);
    // }
    //
    // if (d.eventType == "SceneItemRemoved") {
    //     local.values.getChild("Scenes").getChild(d.eventData.sceneName).removeContainer(d.eventData.sourceName);
    // }
    //
    // if (d.eventType == "SceneCreated") {
    //     EnumScenes.addOption(d.eventData.sceneName, d.eventData.sceneName);
    //     local.values.getChild("Scenes").addContainer(d.eventData.sceneName);
    // }
    //
    // if (d.eventType == "SceneRemoved") {
    //     local.values.getChild("Scenes").removeContainer(d.eventData.sceneName);
    // }
    //
    // if (d.eventType == "SceneNameChanged") {
    //     local.values.getChild("Scenes").getChild(d.eventData.oldSceneName).setName(d.eventData.sceneName);
    //     local.values.getChild("Scenes").getChild(d.eventData.sceneName).getChild("sceneName").set(d.eventData.sceneName);
    //     GetSceneList(7);
    // }
    //
    // if (d.eventType == "InputCreated") {
    //     local.values.getChild("Inputs").addContainer(d.eventData.inputName);
    //     local.values.getChild("Inputs").getChild(d.eventData.inputName).addStringParameter("inputName", "", d.eventData.inputName);
    //     local.values.getChild("Inputs").getChild(d.eventData.inputName).getChild("inputName").setAttribute("readonly", true);
    //     local.values.getChild("Inputs").getChild(d.eventData.inputName).addStringParameter("inputKind", "", d.eventData.inputKind);
    //     local.values.getChild("Inputs").getChild(d.eventData.inputName).getChild("inputKind").setAttribute("readonly", true);
    // }
    //
    // if (d.eventType == "InputRemoved") {
    //     local.values.getChild("Inputs").removeContainer(d.eventData.inputName);
    // }
    //
    // if (d.eventType == "InputNameChanged") {
    //     var tempoEnumItem = EnumItems.getKey();
    //     local.values.getChild("Inputs").getChild(d.eventData.oldInputName).getChild("inputName").set(d.eventData.inputName);
    //     local.values.getChild("Inputs").getChild(d.eventData.oldInputName).setName(d.eventData.inputName);
    //     var sceneList = util.getObjectProperties(local.values.getChild("Scenes"), true, false);
    //     for (var i = 0; i < sceneList.length; i++) {
    //         if (sceneList[i] != "slctScene" && sceneList[i] != "slctItem") {
    //             if (local.values.getChild("Scenes")[sceneList[i]].getChild(d.eventData.oldInputName) != null) {
    //                 local.values.getChild("Scenes")[sceneList[i]].getChild(d.eventData.oldInputName).setName(d.eventData.inputName);
    //             }
    //         }
    //     }
    //     GetSceneItemList("active_items_" + EnumScenes.get(), EnumScenes.get());
    //     util.delayThreadMS(500);
    //     EnumItems.set(tempoEnumItem);
    // }
}