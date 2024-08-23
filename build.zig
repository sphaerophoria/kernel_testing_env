const std = @import("std");

pub fn buildKernel(b: *std.Build) !void {
    const install_path = b.getInstallPath(.prefix, "linux_build");

    const config_copy = b.addInstallFile(b.path("kernel_config"), "linux_build/.config");

    const run = b.addSystemCommand(&.{"make"});
    run.step.dependOn(&config_copy.step);
    run.setCwd(b.path("linux"));
    var buf: [512]u8 = undefined;
    run.addArg(try std.fmt.bufPrint(&buf, "O={s}", .{install_path}));
    run.addArg("-j5");

    b.getInstallStep().dependOn(&run.step);
}

pub fn buildBusybox(b: *std.Build) !void {
    const wf = b.addWriteFiles();
    const config_copy = wf.addCopyFile(b.path("busybox_config"), ".config");

    const run = b.addSystemCommand(&.{"make"});
    run.step.dependOn(config_copy.generated.file.step);
    run.setCwd(b.path("busybox"));
    run.addPrefixedDirectoryArg("O=", wf.getDirectory());
    run.addArgs(&.{"-j5", "CC=musl-gcc"});

    const install = b.addSystemCommand(&.{"make"});
    install.step.dependOn(&run.step);
    install.setCwd(b.path("busybox"));
    install.addPrefixedDirectoryArg("O=", wf.getDirectory());
    install.addArgs(&.{"install", "CC=musl-gcc"});

    const install_path = b.getInstallPath(.prefix, "_install");
    var buf: [512]u8 = undefined;
    install.addArg(try std.fmt.bufPrint(&buf, "CONFIG_PREFIX={s}", .{install_path}));

    b.getInstallStep().dependOn(&install.step);
}

pub fn build(b: *std.Build) !void {
    try buildKernel(b);
    try buildBusybox(b);
}
