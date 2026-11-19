// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com\gmail.com
// Des: Unit tests for history entry output escaping
// Flo: write output into allocating writer > assert no entry mark survives
// I/O: fake stdout text > pass or fail
// ===================================================================
const std = @import("std"); const hist = @import("st-runz-hist.zig"); const tszz = std.testing;
test "bodyWrit indents a lone #### line, keeps the rest byte-exact" { var outz: std.Io.Writer.Allocating = .init(tszz.allocator); defer outz.deinit(); try hist.bodyWrit(&outz.writer, "a\n####\nb ####\n#####\n####"); const got = outz.writer.buffered(); try tszz.expectEqualStrings("a\n ####\nb ####\n#####\n ####", got); try tszz.expect(std.mem.indexOf(u8, got, hist.SEPA_ENTR) == null); }
test "bodyWrit passes plain text and empty input unchanged" { var outz: std.Io.Writer.Allocating = .init(tszz.allocator); defer outz.deinit(); try hist.bodyWrit(&outz.writer, ""); try tszz.expectEqualStrings("", outz.writer.buffered()); try hist.bodyWrit(&outz.writer, "x\r\ny"); try tszz.expectEqualStrings("x\r\ny", outz.writer.buffered()); }
