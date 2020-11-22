// License: MIT
// Dynamic CGI serving using dynamic path imports for 
//      CGI supporting executable for Interpreted languages Embedded Distribution
// Contribution: 2018 Ganesh K. Bhat <ganeshsurfs@gmail.com> 
// 


/* eslint no-console: 0 */

const process = require('process');
const URL = require('url');
const child = require('child_process');
const path = require('path');
const fs = require('fs');
const shell = require('shelljs');
const utils = require('./utils')();


/**
 *
 *
 * @returns {Object}
 */
function cgiServe() {

	let ruby = "ruby", perl = "perl", python = "python", php = "php", node = "node";
	let python3 = ((process.platform === "win32") ? 'python' : 'python3');
	let langOptions = { "name": '', "cgi": '', "which": '', "type": "", "pattern": null };

	// Use addLangOpts(type, options) to add new interpreter options to LANG_OPTS
	let LANG_OPTS = {
		"rb": { "name": ruby, "cgi": ruby, "which": "", "type": "rb", "pattern": /.*?\.rb$/ },
		"pl": { "name": perl, "cgi": perl, "which": "", "type": "pl", "pattern": /.*?\.pl$/ },
		"plc": { "name": perl, "cgi": perl, "which": "", "type": "plc", "pattern": /.*?\.plc$/ },
		"pld": { "name": perl, "cgi": perl, "which": "", "type": "pld", "pattern": /.*?\.pld$/ },
		"py3": { "name": python3, "cgi": python3, "which": "", "type": "py", "pattern": /.*?\.py$/ },
		"py": { "name": python, "cgi": python, "which": "", "type": "py", "pattern": /.*?\.py$/ },
		"php": { "name": php, "cgi": php + "-cgi", "which": "", "type": "php", "pattern": /.*?\.php$/ },
		"node": { "name": node, "cgi": node, "which": "", "type": "node", "pattern": /.*?\.js$/ }
	}


	/**
	 *
	 *
	 * @param {string} msg
	 * @return {throw error}
	 */
	function error(msg) {
		console.error(msg);
		process.exit(msg);
	}

	/**
	 *
	 *
	 * @param {string} action
	 * @param {Object} exeOptions
	 * @returns {string} bin_path / {throw error} 
	 */
	function cleanBinPath(action, exeOptions) {
		if (typeof exeOptions.bin === "string") {
			return exeOptions.bin;
		} else if (typeof exeOptions.bin === "object") {
			if (!!exeOptions.bin.useDefault) {
				return "";
			} else if (!!exeOptions.bin.bin_path) {
				return exeOptions.bin.bin_path;
			} else {
				error("cleanBinPath: bin path config type definition error");
			}
		}
	}


	function validateLangOptionStructure(obj) {
		let k = Object.keys(obj), l = Object.keys(langOptions);
		for (let i = 0; i < l.length; i++) {
			if (k.indexOf(l[i]) >= 0) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Check this again
	 *
	 * @param {string} cgiExecutable
	 * @param {Object} exeOptions
	 * @param {string} type
	 * @returns {bool} / {throw error}
	 */
	function setCGI(type, cgiExecutable, exeOptions) {
		let WHICH_CGI;
		try {
			WHICH_CGI = shell.which(path.join(exeOptions.bin.bin_path, cgiExecutable));
			if (!!LANG_OPTS[type]) {
				LANG_OPTS[type].which = WHICH_CGI;
			} else {
				error("setCGI: CGI Executable type apply error");
			}
		} catch (e) {
			error("setCGI: CGI Executable fetch error");
		}
		return true;
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @param {Object} exeOptions
	 * @returns {string} WHICH_CGI
	 */
	function getCGI(type, exeOptions) {
		let WHICH_CGI;
		try {
			if (!LANG_OPTS[type].which) {
				setCGI(type, LANG_OPTS[type], exeOptions);
			}
			WHICH_CGI = LANG_OPTS[type].which;
		} catch (e) {
			error("getCGI: CGI Executable fetch error");
			return false;
		}
		return WHICH_CGI;
	}

	/**
	 *
	 *
	 * @param {string} cgiLang
	 * @returns {bool} / {throw error}
	 */
	function setCGITypes(cgiLang) {
		if (Array.isArray(cgiLang)) {
			for (let i = 0; i < cgiLang.length; i++) {
				let res = validateLangOptionStructure(cgiLang[i]);
				if (!res) { return res; }
			}
			langOptions.push(...cgiLang);
			return true;
		} else if (typeof (cgiLang) === 'object') {
			let res = validateLangOptionStructure(cgiLang[i]);
			if (!res) { return res; }
			langOptions.push(cgiLang);
			return true;
		}
		error("setCGITypes: Incorrect Type provided");
	}


	/**
	 *
	 * @param {string, array} cgiLang
	 * @returns {Object} LANG_OPTS / {string} LANG_OPTS[type]
	 */
	function getCGITypes(cgiLang) {
		if (typeof (cgiLang) === 'string') {
			return LANG_OPTS[cgiLang];
		} else if (Array.isArray(cgiLang)) {
			let l = [];
			for (let i = 0; i < cgiLang.length; i++) {
				l.push(cgiLang[i]);
			}
			return l;
		}
		return LANG_OPTS;
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @param {Object} exeOptions
	 * @returns {Object} {LANG_OPTS, exeOptions}
	 */
	function pathClean(exeOptions) {
		exeOptions.bin = { bin_path: cleanBinPath("getCGI", exeOptions) };
		return {
			LANG_OPTS: LANG_OPTS,
			exeOptions: exeOptions
		};
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @param {Object} exeOptions
	 * @returns {Object} {LANG_OPTS, exeOptions}
	 */
	function getVars(exeOptions) {
		return pathClean(exeOptions);
	}


	/**
	 *
	 *
	 * @param {string} pathinfo
	 * @param {string} file
	 * @param {Object request} req
	 * @param {Object url} url
	 * @param {string} host
	 * @param {int} port
	 * @returns {Object} env(environment)
	 */
	function getEnv(pathinfo, file, req, url, host, port) {

		var env = {
			SERVER_SIGNATURE: 'NodeJS server at localhost',

			// The extra path information, as given in the requested URL. In fact, scripts can be accessed by their virtual path, followed by extra information at the end of this path. The extra information is sent in PATH_INFO.
			PATH_INFO: pathinfo,

			// The virtual-to-real mapped version of PATH_INFO.
			PATH_TRANSLATED: '',

			// The virtual path of the script being executed.
			SCRIPT_NAME: url.pathname,

			SCRIPT_FILENAME: file,

			// The real path of the script being executed.
			REQUEST_FILENAME: file,

			// The full URL to the current object requested by the client.
			SCRIPT_URI: req.url,

			// The full URI of the current request. It is made of the 
			// 			concatenation of SCRIPT_NAME and PATH_INFO (if available.)
			URL: req.url,

			SCRIPT_URL: req.url,

			// The original request URI sent by the client.
			REQUEST_URI: req.url,

			// The method used by the current request; usually set to GET or POST.
			REQUEST_METHOD: req.method,

			// The information which follows the ? character in the requested URL.
			QUERY_STRING: url.query || '',

			// 'multipart/form-data', //'application/x-www-form-urlencoded', 
			//The MIME type of the request body; set only for POST or PUT requests.
			CONTENT_TYPE: req.get('Content-Type') || '',

			// The length in bytes of the request body; set only for POST or PUT requests.
			CONTENT_LENGTH: req.get('Content-Length') || 0,

			// The authentication type if the client has authenticated itself to access the script.
			AUTH_TYPE: '',

			AUTH_USER: '',

			// The name of the user as issued by the client when authenticating itself to 
			// 			access the script.
			REMOTE_USER: '',

			// All HTTP headers sent by the client. Headers are separated by carriage return 
			// 		characters (ASCII 13 - \n) and each header name is prefixed by HTTP_, 
			// 		transformed to upper cases, and - characters it contains are replaced by _ characters.
			ALL_HTTP: Object.keys(req.headers).map(function (x) {
				return 'HTTP_' + x.toUpperCase().replace('-', '_') + ': ' + req.headers[x];
			}).reduce(function (a, b) {
				return a + b + '\n';
			}, ''),

			// All HTTP headers as sent by the client in raw form. No transformation 
			// 			on the header names is applied.
			ALL_RAW: Object.keys(req.headers).map(function (x) {
				return x + ': ' + req.headers[x];
			}).reduce(function (a, b) {
				return a + b + '\n';
			}, ''),

			// The web server's software identity.
			SERVER_SOFTWARE: 'NodeJS',

			// The host name or the IP address of the computer running the web server 
			// 			as given in the requested URL.
			SERVER_NAME: 'localhost',

			// The IP address of the computer running the web server.
			SERVER_ADDR: host,

			// The port to which the request was sent.
			SERVER_PORT: port,

			// The CGI Specification version supported by the web server; always set to CGI/1.1.
			GATEWAY_INTERFACE: 'CGI/1.1',

			// The HTTP protocol version used by the current request.
			SERVER_PROTOCOL: '',

			// The IP address of the computer that sent the request.
			REMOTE_ADDR: req.ip || '',

			// The port from which the request was sent.
			REMOTE_PORT: '',

			// The absolute path of the web site files. It has the same value as Documents Path.
			DOCUMENT_ROOT: '',

			// The numerical identifier of the host which served the request. On Abyss Web 
			// 			Server X1, it is always set to 1 since there is only a single host.
			INSTANCE_ID: '',

			// The virtual path of the deepest alias which contains the request URI. If no alias 
			// 			contains the request URI, the variable is set to /.
			APPL_MD_PATH: '',

			// The real path of the deepest alias which contains the request URI. If no alias 
			// 			contains the request URI, the variable is set to the same value as DOCUMENT_ROOT.
			APPL_PHYSICAL_PATH: '',

			// It is set to true if the current request is a subrequest, i.e. a request not 
			// 			directly invoked by a client. Otherwise, it is set to true. Subrequests 
			// 			are generated by the server for internal processing. XSSI includes for 
			// 			example result in subrequests.
			IS_SUBREQ: '',

			REDIRECT_STATUS: 1
		};
		return env;
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @returns {^regex pattern} pattern / {throw error}
	 */
	function getPattern(type) {
		let ty = LANG_OPTS[type];
		if (!!ty && !!ty.pattern && ty.pattern !== "") {
			return ty.pattern;
		}
		error("getPattern: Pattern does not exist ", pattern);
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @returns {string} type / {throw error}
	 */
	function getType(type) {
		let ty = LANG_OPTS[type];
		if (!!ty && !!ty.type && ty.type !== "") {
			return ty.type;
		}
		error("getType: Type does not exist ", type);
	}


	/**
	 *
	 *
	 * @param {array} lines
	 * @param {Object} res
	 * @returns {Object} {html, res}
	 */
	function getPHPHtml(lines, res) {

		var line = 0;
		do {
			var m = lines[line].split(': ');
			if (m[0] === '') break;
			if (m[0] == 'Status') {
				res.statusCode = parseInt(m[1]);
			}
			if (m.length == 2) {
				res.setHeader(m[0], m[1]);
			}
			line++;
		} while (lines[line] !== '');

		html = lines.splice(line + 1).join('\n')

		return {
			html: html,
			res: res
		};
	}


	/**
	 *
	 *
	 * @param {string} lines
	 * @param {Object res} res
	 * @returns {Object} {html, res}
	 */
	function getCGIHtml(lines, res) {
		var line = 0;
		for (var i = 0; i < lines.length; i++) {
			if (lines[line] !== '') {
				try {
					var m = lines[line].split(': ');
					if (m[0] === '') break;
					if (m[0] == 'Status') {
						res.statusCode = parseInt(m[1]);
					}
					if (m.length == 2) {
						res.setHeader(m[0], m[1]);
					}
				} catch (err) {
					console.error("getCGIHtml: ", err)
				}
			}
		}

		html = lines.join('\n')

		return {
			html: html,
			res: res
		};
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @param {Object} exeOptions
	 * @returns {Object promise} resolve(file/bool)
	 */
	function fileExists(type, exeOptions) {
		let promise = new Promise(function (resolve, reject) {
			let feFn = function (f) {
				(!!f) ? resolve(f) : resolve(false);
			}
			let file = path.join(exeOptions.web_root_folder);

			fs.stat(file, function (err, stat) {
				// File does not exist
				if (err || stat.isDirectory()) {
					if (stat && stat.isDirectory()) {
						file = path.join(file, 'index.' + type);
						// console.log("fileExists: Path created file ", file);
					}
					if (file.includes(process.cwd())) {
						fs.exists(file, function (exists) {
							// console.log("fileExists: Path join", file, exists);
							if (!!exists) {
								feFn(file);
							}
						});
					} else {
						fs.exists(path.join(process.cwd(), file), function (exists) {
							// console.log("fileExists: No path join", file, exists);
							if (!!exists) {
								feFn(file);
							}
						});
					}
				}

				// File found
				else {
					console.log("fileExists: Else Path", file);
					callback(file);
				}
			});
		});
		return promise;
	}


	/**
	 *
	 *
	 * @param {Object req} req
	 * @param {Object res} res
	 * @param {Object next} next
	 * @param {Object url} url
	 * @param {string} type
	 * @param {string} file
	 * @param {^regex pattern} pattern_chk
	 * @param {Object} exeOptions
	 * @returns
	 */
	function runCGI(req, res, next, url, type, file, pattern_chk, exeOptions) {
		let index = req.originalUrl.indexOf('.' + type);
		let pathinfo = (index >= 0) ? url.pathname.substring(index + type.length + 1) : url.pathname;
		let env = getEnv(pathinfo, file, req, url.pathname, exeOptions.host, exeOptions.port);

		Object.keys(req.headers).map(function (x) {
			return env['HTTP_' + x.toUpperCase().replace('-', '_')] = req.headers[x];
		});

		if (!!pattern_chk.test(path.join(process.cwd(), file))) {
			let tmp_result = '', err = '', proc, executable;

			if ((!!exeOptions.bin.bin_path) && (('/' + LANG_OPTS[type].cgi).length !== exeOptions.bin.bin_path.length)) {
				// console.log('runCGI: 1', exeOptions.bin.bin_path);
				executable = exeOptions.bin.bin_path + "/" + LANG_OPTS[type].cgi;

			} else {
				// console.log('runCGI: 2', exeOptions.bin.bin_path.split('/')[1]);
				if (!LANG_OPTS[type]["which"]) {
					error('"runCGI: cgi executable" cannot be found, "which" Error');
				}
				let p = exeOptions.bin.bin_path.split('/')[1];
				executable = ((!!p) ? p + "/" : "") + LANG_OPTS[type].cgi;
			}

			proc = child.spawn(executable, [...utils.convert.array(exeOptions.cmd_options), file], {
				cwd: process.cwd(),
				env: env
			});

			proc.stdin.on('error', function () {
				error("runCGI: Error from server");
			});

			// Pipe request stream directly into the php process
			req.pipe(proc.stdin);
			req.resume();

			proc.stdout.on('data', function (data) {
				tmp_result += data.toString();
			});

			proc.stderr.on('data', function (data) {
				err += data.toString();
			});

			proc.on('error', function (err) {
				if (res.statusCode) {
					return res.status(res.statusCode).send("runCGI: error event" + err.toString());
				} else {
					return res.send(500, "runCGI: error event" + err.toString());
				}
			});

			proc.on('exit', function () {
				// extract headers
				proc.stdin.end();

				let lines = tmp_result.split('\r\n');
				let html = '', CGIObj = {};

				if (lines.length) {
					if (type == "php") {
						CGIObj = getPHPHtml(lines, res);
						html = CGIObj["html"];
						res = CGIObj["res"];
					} else {
						CGIObj = getCGIHtml(lines, res);
						html = CGIObj["html"];
						res = CGIObj["res"];
					}
				} else {
					html = tmp_result;
				}

				if (res.statusCode) {
					return res.status(res.statusCode).send(html);
				} else {
					return res.send(html);
				}
				return res.end();
			});
		} else {
			return res.sendFile(file);
		}
	}


	/**
	 *
	 *
	 * @param {string} type
	 * @param {Object} exeOptions
	 * @returns
	 */
	function serve(type, exeOptions) {
		type = getType(type);
		let pattern = getPattern(type);
		let gvars = getVars(exeOptions);
		exeOptions = gvars.exeOptions;

		let exe = setCGI(type, LANG_OPTS[type].cgi, exeOptions);
		if (!exe) {
			error("serve: Exe setCGI failed");
		}

		return function (req, res, next) {
			try {
				// stop stream until child-process is opened
				req.pause();
				var req_url = URL.parse(req.originalUrl);

				fileExists(type, exeOptions).then(function (file) {
					if (!!file) {
						runCGI(req, res, next, req_url, type, file, pattern, exeOptions);
					} else {
						res.end("serve: File serve exists error: 1");
					}
				}).catch(function (e) {
					res.end("serve: File serve promise error: 2" + e.toString());
				});
			} catch (e) {
				res.end("serve: File serve promise error: 3", e.toString());
			}
		};
	}


	return {
		setter: {
			which: setCGI,
			cgiTypes: setCGITypes
		},
		getter: {
			which: getCGI,
			cgiTypes: getCGITypes,
			vars: getVars,
			env: getEnv
		},
		runCGI: runCGI,
		serve: serve
	}
}

exports.serve = cgiServe;

