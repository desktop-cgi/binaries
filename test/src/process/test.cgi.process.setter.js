/*
 * 
 * TESTS SETTER FUNCTIONS
 * 
*/


var obj = require("../../../src/process")();
const cgijs = require("../../../src");
var events = require('events');
const path = require("path");
const { assert } = require("console");
const { json } = require("express");
var eventEmitter = new events.EventEmitter();
const os = require("os");


if (__dirname.toString().includes("src/process")) {
    var args = [path.join(__dirname, "../../../www/node/index.js")];
} else {
    var args = [path.join(__dirname, "./www/node/index.js")];
}


var proc = obj.process.set({
    name: "nodefileexecute",
    // --> executableOptions
    type: "executable",
    // --> osList
    os: "win32",
    // --> any executable or systemctl
    exe: "node",
    cmds: {
        generic: { usage: "", args: args }
    },
    options: {
        stdio: 'inherit',
        shell: true
    },
    other: {
        paths: {
            "conf": "",
            "exe": "",
            "anyotherpaths": ""
        },
        env: "",
        command: "generic"
    }
});


function testProcessSetter() {

    var prc = obj.process.get("nodefileexecute");

    console.log("Starting Tests");

    assert(prc.name === "nodefileexecute", "Testing Correct getter for process");
    assert(prc.exe === "node", "Testing Correct object [exe] process");
    assert(prc.cmds["generic"].usage === "", "Testing Correct object [cmds.generic.usage] process");
    assert(prc.cmds["generic"].args === args, "Testing Correct object [cmds.generic.args] process");
    assert(prc.other.command === "generic", "Testing Correct object [other.command] process");

    console.log("Ending Tests");

}

testProcessSetter();
