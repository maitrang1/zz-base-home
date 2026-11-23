// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Fault-injection counter used only by tests
// Flo: count steps > fail at the chosen step > never fails when unset
// I/O: optional step index > error.Injected at that step
// ===================================================================
pub const Tick = struct {
left: ?usize = null,
seen: usize = 0,
pub fn step(self: *Tick) !void {
self.seen += 1;
if (self.left) |lft| {
if (lft == 0) return error.Injected;
self.left = lft - 1;
}
}
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
