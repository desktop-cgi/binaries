

const obj = require("../../../src/process")();
const cgijs = require("../../../src");
const events = require('events');
const path = require("path");
const os = require("os");
const { assert } = require("console");
const { json } = require("express");
const eventEmitter = new events.EventEmitter();



var myEventHandler = function (prc) {
    setTimeout(function () {

        console.log("Closing Process PID: ", prc.pid);
        // console.log("Process Object: ", prc);
        console.log("Starting process kill tests for executeAction: ", prc.pid);
        if (obj.process.kill(prc.pid, 1)) {
            try {
                assert(obj.process.kill(prc.pid, 0), "obj.process.kill(prc.pid, 0) worked")
            }
            catch (e) {
                assert(false, "obj.process.kill(prc.pid, 0) failed")
            }
            console.log("Closed Process PID: ", prc.pid);
            prc = null;
        }
        console.log("Ending process kill tests for executeAction: Above are the test failures");
        console.log("Closing Node Process: ", process.pid);
        process.exit();
    }.bind(prc, obj), 10000);
}

eventEmitter.on('closeprocess', myEventHandler.bind(obj));



let proc = obj.process.executeProcess({
    name: "lscommand",
    type: "executable",
    os: "",
    exe: "",
    cmds: {
        generic: { exe: path.join(__dirname, "test.cgi.process.exec.js"), usage: "", args: [] }
    },
    options: {
        stdio: 'inherit',
        shell: true
    },
    other: {
        paths: {
            "conf": "",
            "exe": ""
        },
        env: "",
        setprocess: true,
        executetype: "fork",
        command: "generic"
    }
}, {
    stdio: 'inherit',
    shell: true
}, (error, stdout, stderr) => {
    console.log("Starting Tests for test.cgi.process.executeProcess.fork dataHandlers tests")
    assert(stdout.process.spawnfile.includes('C:\\Program Files\\nodejs\\node.exe'), "stdout.process.spawnfile.includes('C:\\Program Files\\nodejs\\node.exe')")
    assert(stdout.process.spawnargs.includes('C:\\Program Files\\nodejs\\node.exe'), 'stdout.process.spawnargs.includes(\'C:\\Program Files\\nodejs\\node.exe\')')
    assert(stdout.process.spawnargs.indexOf('ls'), 'stdout.process.spawnargs.includes("ls")')
    assert(stdout.process.spawnargs.indexOf(''), 'stdout.process.spawnargs.includes("")')
    console.log("Ending Tests: with above failure test.cgi.process.executeProcess.fork dataHandlers tests")
    eventEmitter.emit('closeprocess', stdout);
}, (options, proc) => {
    console.log("Starting Tests for test.cgi.process.executeProcess.fork close handlers tests")
    assert(options === null, "Options result for closing handler is null")
    assert(proc === 0, "Options result for closing handler is null")
    console.log("Ending Tests: with above failure test.cgi.process.executeProcess.fork close handlers tests");
});


