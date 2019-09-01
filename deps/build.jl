using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcddgmp"], :libcddgmp),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/benlorenz/cddlibBuilder/releases/download/v0.94.0-j-3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/cddlib.v0.94.0-j+.aarch64-linux-gnu.tar.gz", "6922cd1b3f8995921d43f9674bd0c50fd702707efa009bdefbc2e292a5d082c9"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/cddlib.v0.94.0-j+.aarch64-linux-musl.tar.gz", "f86e0dc2db85c04bfeb088b783e2881d444db891d22eab4de6f0765ca4e4942a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/cddlib.v0.94.0-j+.arm-linux-gnueabihf.tar.gz", "2aa80242f8989d48ba29a92cc81bbeee708e3b5543f37e1f24a7941696a2ba4c"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/cddlib.v0.94.0-j+.arm-linux-musleabihf.tar.gz", "c62207c9c1c015d4f7516035ae15a85bf2385bca4399ff61b7a705c8a88659c9"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/cddlib.v0.94.0-j+.i686-linux-gnu.tar.gz", "a3ccd4cbbe9fc7d4d5b3b9936590081fcb268d7eef4f8ffd984a5064756096fd"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/cddlib.v0.94.0-j+.i686-linux-musl.tar.gz", "bbe069142cadb6769ff130b7827ee86f0b853e5120bd3c42bae6317f92654a40"),
    Windows(:i686) => ("$bin_prefix/cddlib.v0.94.0-j+.i686-w64-mingw32.tar.gz", "53f1bd3a33ab933768e76a6e7d9b0dbb2af88f71c4d72086c4d34c54483ae93c"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/cddlib.v0.94.0-j+.powerpc64le-linux-gnu.tar.gz", "eb8327163776e8308bb70368626743a5284e8986961021cf123a15bbf5ff1bde"),
    MacOS(:x86_64) => ("$bin_prefix/cddlib.v0.94.0-j+.x86_64-apple-darwin14.tar.gz", "20e1e9f762fba394be0255d25069c74134ac8a16913660f728cb6fdfb8a7297c"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/cddlib.v0.94.0-j+.x86_64-linux-gnu.tar.gz", "796826f677ea5e65939296f6dda2a4eba09dd3193eabffd2d288e4c338916456"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/cddlib.v0.94.0-j+.x86_64-linux-musl.tar.gz", "20beb66706322c8978aabd0c4314207546e052ec8ce92bc3ddcac3d0ec8bb08f"),
    FreeBSD(:x86_64) => ("$bin_prefix/cddlib.v0.94.0-j+.x86_64-unknown-freebsd11.1.tar.gz", "5b7a4a3e7501454f37d35c6ab73f17edad0d814fcfb088e3c9fb17ff4f5c885b"),
    Windows(:x86_64) => ("$bin_prefix/cddlib.v0.94.0-j+.x86_64-w64-mingw32.tar.gz", "eccb4c40ae6657454e7ac2e6f815e167d264df7253866595e3d4bad7c9e092b3"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    evalfile("build_GMP.v6.1.2.jl")  # We do not check for already installed GMP libraries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
