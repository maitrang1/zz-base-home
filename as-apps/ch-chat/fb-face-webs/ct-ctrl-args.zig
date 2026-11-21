// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read command line words into one Args struct
// Flo: walk argv > flags (with or without a value) > up to 3 plain words (command, sub, extra) > safety checks
// I/O: argv slice (caller) > Args; error BadUsage on unknown flag, missing value, or --force without --live
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig");
const VALS = [_][]const u8{ "--text", "--to", "--url", "--title", "--price", "--desc", "--group", "--photo", "--opt", "--date", "--time", "--catg", "--cond", "--loca" };
pub const Args = struct { cmdz: []const u8 = "", subz: []const u8 = "", extr: []const u8 = "", json: bool = false, live: bool = false, forc: bool = false, read: bool = false, head: bool = false, helz: bool = false, yesz: bool = false, conf: []const u8 = "", tsk: task.Args = .{},
pub fn mode(self: Args) task.Mode { if (self.read) return .read; if (self.forc) return .force; if (self.live) return .live; return .dry; } };
pub fn argsRead(argv: []const []const u8) !Args { var args: Args = .{}; var indx: usize = 0; while (indx < argv.len) : (indx += 1) { const item = argv[indx]; if (std.mem.eql(u8, item, "--json")) { args.json = true; continue; } if (std.mem.eql(u8, item, "--live")) { args.live = true; continue; } if (std.mem.eql(u8, item, "--force")) { args.forc = true; continue; } if (std.mem.eql(u8, item, "--read")) { args.read = true; continue; } if (std.mem.eql(u8, item, "--head")) { args.head = true; continue; } if (std.mem.eql(u8, item, "--yes")) { args.yesz = true; continue; } if (std.mem.eql(u8, item, "--dry")) continue; if (std.mem.eql(u8, item, "--help") or std.mem.eql(u8, item, "-h")) { args.helz = true; continue; }
if (std.mem.eql(u8, item, "--conf") or std.mem.eql(u8, item, "--max")) { indx += 1; if (indx >= argv.len) return error.BadUsage; if (item[2] == 'c') args.conf = argv[indx] else args.tsk.maxn = std.fmt.parseInt(u32, argv[indx], 10) catch return error.BadUsage; continue; } var done = false; inline for (VALS) |nam| { if (!done and std.mem.eql(u8, item, nam)) { indx += 1; if (indx >= argv.len) return error.BadUsage; @field(args.tsk, nam[2..]) = argv[indx]; done = true; } } if (done) continue;
if (item.len > 1 and item[0] == '-' and item[1] == '-') return error.BadUsage; if (args.cmdz.len == 0) { args.cmdz = item; } else if (args.subz.len == 0) { args.subz = item; } else if (args.extr.len == 0) { args.extr = item; } else return error.BadUsage; } if (args.forc and !args.live) return error.BadUsage; if (args.read and (args.live or args.forc)) return error.BadUsage; return args; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
