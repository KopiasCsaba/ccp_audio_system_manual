// Authentication - maps password -> role config
// tabs: null means all tabs visible; tabs: ['TabName', ...] restricts to those tabs
const ROLES = {
    'Admin777':    { tabs: null },
    'makeitshort': { tabs: ['Good'] }
};

// Image and layout constants (exported 500dpi)
const IMG_WIDTH = 2255;
const IMG_HEIGHT = 1292;

// Actual measured values from bg.png
const KEY_WIDTH = 256;
const KEY_HEIGHT = 256;
const COL_STEP = KEY_WIDTH + 144;  // 453 + 256 gap
const ROW_STEP = KEY_HEIGHT + 90;  // Row spacing

// Display scale factor for the buttons (can be modified)
let SCALE = 0.5;

const CONFIG = {
    // For this a reverse proxy was needed in the NAS: https://n8n.local:8888 -> 192.168.2.5:3000
    // Using IP instead of n8n.local for mobile compatibility
    // If HTTPS fails on mobile (certificate error), try HTTP or accept cert first
    webhook_url: "/n8n/webhook/keyinput",
    actions: {
        // Row 0 - Primary (Camera Move Presets) - top half of physical row 1
        "pulpit_wide": {
            keycombination: {v: "c", c: 32, ctrl: false, shift: false, alt: true, meta: true},
            label: "PULPIT WIDE",
            is_secondary: false,
            row: 0, col: 0,
            is_hold: false
        },
        "pulpit": {
            keycombination: {v: "d", c: 31, ctrl: false, shift: false, alt: true, meta: true},
            label: "PULPIT",
            is_secondary: false,
            row: 0, col: 1,
            is_hold: false
        },
        "stage": {
            keycombination: {v: "s", c: 18, ctrl: false, shift: false, alt: true, meta: true},
            label: "STAGE",
            is_secondary: false,
            row: 0, col: 2,
            is_hold: false
        },
        "projector_canvas": {
            keycombination: {v: "g", c: 46, ctrl: false, shift: false, alt: true, meta: true},
            label: "PROJECTOR CANVAS",
            is_secondary: false,
            row: 0, col: 3,
            is_hold: false
        },
        "sitting": {
            keycombination: {v: "t", c: 20, ctrl: false, shift: false, alt: true, meta: true},
            label: "SITTING",
            is_secondary: false,
            row: 0, col: 4,
            is_hold: false
        },
        "custom_angle": {
            keycombination: {v: "f", c: 33, ctrl: false, shift: false, alt: true, meta: true},
            label: "CUSTOM ANGLE",
            is_secondary: false,
            row: 0, col: 5,
            is_hold: false
        },

        // Row 0 - Secondary (Events) - bottom half of physical row 1
        "pre_stream": {
            keycombination: {v: "c", c: 46, ctrl: true, shift: false, alt: true, meta: true},
            label: "PRE STREAM",
            is_secondary: true,
            row: 0, col: 0,
            is_hold: false
        },
        "break": {
            keycombination: {v: "d", c: 32, ctrl: true, shift: false, alt: true, meta: true},
            label: "BREAK",
            is_secondary: true,
            row: 0, col: 1,
            is_hold: false
        },
        "finish": {
            keycombination: {v: "s", c: 31, ctrl: true, shift: false, alt: true, meta: true},
            label: "FINISH",
            is_secondary: true,
            row: 0, col: 2,
            is_hold: false
        },
        "change_preset": {
            keycombination: {v: "g", c: 20, ctrl: true, shift: false, alt: true, meta: true},
            label: "CHANGE PRESET",
            is_secondary: true,
            row: 0, col: 3,
            is_hold: false
        },
        "fade_to_black": {
            keycombination: {v: "t", c: 34, ctrl: true, shift: false, alt: true, meta: true},
            label: "FADE TO BLACK",
            is_secondary: true,
            row: 0, col: 4,
            is_hold: false
        },
        "save_custom_angle": {
            keycombination: {v: "f", c: 33, ctrl: true, shift: false, alt: true, meta: true},
            label: "SAVE C. ANGLE",
            is_secondary: true,
            row: 0, col: 5,
            is_hold: false
        },

        // Row 1 - Camera Zoom/Pan Controls (full height) - physical row 2
        "zoom_in": {
            keycombination: {v: "9", c: 10, ctrl: false, shift: false, alt: true, meta: true},
            label: "+ CAM",
            is_secondary: false,
            row: 1, col: 0,
            is_hold: true
        },
        "cam_up": {
            keycombination: {v: "1", c: 2, ctrl: false, shift: false, alt: true, meta: true},
            label: "UP CAM",
            is_secondary: false,
            row: 1, col: 1,
            is_hold: true
        },
        "zoom_out": {
            keycombination: {v: "a", c: 30, ctrl: false, shift: false, alt: true, meta: true},
            label: "- CAM",
            is_secondary: false,
            row: 1, col: 2,
            is_hold: true
        },
        "cam_upleft": {
            keycombination: {v: "o", c: 24, ctrl: false, shift: false, alt: true, meta: true},
            label: "UP-LEFT CAM",
            is_secondary: false,
            row: 1, col: 3,
            is_hold: true
        },
        "cam_upright": {
            keycombination: {v: "q", c: 16, ctrl: false, shift: false, alt: true, meta: true},
            label: "UP-RIGHT CAM",
            is_secondary: false,
            row: 1, col: 4,
            is_hold: true
        },
        "itsgood": {
            keycombination: {v: "p", c: 25, ctrl: false, shift: false, alt: true, meta: true},
            label: "It's GOOD!",
            is_secondary: false,
            row: 1, col: 5,
            is_hold: false,
            disabled: false,
            textualnotify: true
        },

        // Row 2 - Camera Movement (physical row 3)
        // Cols 0-2: full height, Cols 3-5: have secondary
        "cam_left": {
            keycombination: {v: "3", c: 4, ctrl: false, shift: false, alt: true, meta: true},
            label: "LEFT CAM",
            is_secondary: false,
            row: 2, col: 0,
            is_hold: true
        },
        "cam_down": {
            keycombination: {v: "2", c: 3, ctrl: false, shift: false, alt: true, meta: true},
            label: "DOWN CAM",
            is_secondary: false,
            row: 2, col: 1,
            is_hold: true
        },
        "cam_right": {
            keycombination: {v: "4", c: 5, ctrl: false, shift: false, alt: true, meta: true},
            label: "RIGHT CAM",
            is_secondary: false,
            row: 2, col: 2,
            is_hold: true
        },
        "cam_downleft": {
            keycombination: {v: "u", c: 22, ctrl: false, shift: false, alt: true, meta: true},
            label: "DOWN-LEFT CAM",
            is_secondary: false,
            row: 2, col: 3,
            is_hold: true
        },
        "cam_downright": {
            keycombination: {v: "v", c: 47, ctrl: false, shift: false, alt: true, meta: true},
            label: "DOWN-RIGHT CAM",
            is_secondary: false,
            row: 2, col: 4,
            is_hold: true
        },
        "projection_key_toggle": {
            keycombination: {v: "w", c: 17, ctrl: true, shift: false, alt: true, meta: true},
            label: "PROJECTION KEY TOGGLE",
            is_secondary: true,
            row: 2, col: 5,
            is_hold: false
        },

        // Row 2 - Secondary (Key Toggles)
        "avpc_key_toggle": {
            keycombination: {v: "u", c: 22, ctrl: true, shift: false, alt: true, meta: true},
            label: "A/V PC KEY TOGGLE",
            is_secondary: true,
            row: 2, col: 3,
            is_hold: false
        },
        "pulpit_key_toggle": {
            keycombination: {v: "v", c: 47, ctrl: true, shift: false, alt: true, meta: true},
            label: "PULPIT KEY TOGGLE",
            is_secondary: true,
            row: 2, col: 4,
            is_hold: false
        },

        // Row 3 - FN row (physical row 4)
        // Col 0: FN (full), Col 1: split (SHOW BG / PIP), Cols 2-5: full magenta
        "fn": {
            keycombination: null,
            label: "FN",
            is_secondary: false,
            row: 3, col: 0,
            is_hold: false,
            disabled: true
        },
        "show_bg": {
            keycombination: {v: "x", c: 45, ctrl: false, shift: false, alt: true, meta: true},
            label: "SHOW BG",
            is_secondary: false,
            row: 3, col: 1,
            is_hold: false
        },
        "pip_presenter": {
            keycombination: {v: "x", c: 45, ctrl: true, shift: false, alt: true, meta: true},
            label: "P-I-P PRESENTER",
            is_secondary: true,
            row: 3, col: 1,
            is_hold: false
        },
        "show_camera": {
            keycombination: {v: "y", c: 21, ctrl: false, shift: false, alt: true, meta: true},
            label: "SHOW CAMERA",
            is_secondary: false,
            row: 3, col: 2,
            is_hold: false
        },
        "avpc_toggle": {
            keycombination: {v: "m", c: 50, ctrl: false, shift: false, alt: true, meta: true},
            label: "A/V PC TOGGLE",
            is_secondary: false,
            row: 3, col: 3,
            is_hold: false
        },
        "pulpit_toggle": {
            keycombination: {v: "l", c: 38, ctrl: false, shift: false, alt: true, meta: true},
            label: "PULPIT TOGGLE",
            is_secondary: false,
            row: 3, col: 4,
            is_hold: false
        },
        "projection_toggle": {
            keycombination: {v: "k", c: 37, ctrl: false, shift: false, alt: true, meta: true},
            label: "PROJ. TOGGLE",
            is_secondary: false,
            row: 3, col: 5,
            is_hold: false
        }
    },

    // Tab configuration - each tab specifies rows/cols for grid layout
    tabs: {
        "ALL": {
            rows: 7,
            cols: 6,
            keys: [
                // Row 0 (primary from physical row 1)
                "pulpit_wide", "pulpit", "stage", "projector_canvas", "sitting", "custom_angle",
                // Row 1 (secondary from physical row 1)
                "pre_stream", "break", "finish", "change_preset", "fade_to_black", "save_custom_angle",
                // Row 2 (physical row 2 - full height)
                "zoom_in", "cam_up", "zoom_out", "cam_upleft", "cam_upright","itsgood",
                // Row 3 (primary from physical row 3)
                "cam_left", "cam_down", "cam_right", "cam_downleft", "cam_downright", null,
                // Row 4 (secondary from physical row 3)
                null, "pip_presenter", null, "avpc_key_toggle", "pulpit_key_toggle", "projection_key_toggle",
                // Row 5 (physical row 4 - primary)
                null, "show_bg", "show_camera", "avpc_toggle", "pulpit_toggle", "projection_toggle",

            ]
        },
        "Toggles": {
            rows: 2,
            cols:3,
            keys: [
                null,"show_bg", "show_camera",
                "avpc_toggle", "pulpit_toggle", "projection_toggle"
            ]
        },
        "Cam": {
            rows: 2,
            cols: 6,
            keys: [
                "pulpit_wide", "pulpit", "stage", "projector_canvas", "sitting", "custom_angle",
                null, null, null, null, null, "save_custom_angle",
                "zoom_in", "cam_up", "zoom_out", "cam_upleft", "cam_upright",null,
                "cam_left", "cam_down", "cam_right", "cam_downleft", "cam_downright",null,
            ]
        },
        "Event": {
            rows: 1,
            cols: 3,
            scale: 2.0,
            keys: ["pre_stream", "break", "finish"]
        },

        "Pulpit": {
            rows: 1,
            cols:1,
            scale: 4.0,
            keys: [
                 "pulpit_toggle"
            ]
        },

        "Projection": {
            rows: 1,
            cols:1,
            scale: 4.0,
            keys: [
               "projection_toggle"
            ]
        },
      "Good": {
            rows: 1,
            cols:1,
            scale: 4.0,
            keys: [
               "itsgood"
            ]
        },

    }
};
