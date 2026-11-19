// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Run an outside tool, capture output, swappable seam
// Flo: copy parent env + extra pairs > spawn argv > wait > return exit code + stdout + stderr
// I/O: argv + env pairs > Outp {code, stdout, stderr}; error.ToolAbsent when the exe is not found
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 16 * 1024 * 1024 };
pub const Erro = error{ToolAbsent};
pub const Outp = struct { code: u8, outz: []u8, errz: []u8 };
pub const Envp = [2][]const u8;
pub const Runn = struct {
ctxz: *anyopaque,
runz: *const fn (ctxz: *anyopaque, allo: std.mem.Allocator, argv: []const []const u8, envp: []const Envp) anyerror!Outp,
pub fn exec(self: Runn, allo: std.mem.Allocator, argv: []const []const u8, envp: []const Envp) !Outp { return self.runz(self.ctxz, allo, argv, envp); }
};
pub const Real = struct {
iozz: std.Io,
envm: *const std.process.Environ.Map,
pub fn runn(self: *Real) Runn { return .{ .ctxz = self, .runz = realRunz }; }
};
fn realRunz(ctxz: *anyopaque, allo: std.mem.Allocator, argv: []const []const u8, envp: []const Envp) anyerror!Outp {
const self: *Real = @ptrCast(@alignCast(ctxz));
var envm = try self.envm.clone(allo);
defer envm.deinit();
for (envp) |pair| try envm.put(pair[0], pair[1]);
const resu = std.process.run(allo, self.iozz, .{ .argv = argv, .environ_map = &envm, .stdout_limit = .limited(CF.maxz), .stderr_limit = .limited(CF.maxz) }) catch |err| switch (err) { error.FileNotFound => return Erro.ToolAbsent, else => return err };
const code: u8 = switch (resu.term) { .exited => |val| val, else => 255 };
return .{ .code = code, .outz = resu.stdout, .errz = resu.stderr };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
