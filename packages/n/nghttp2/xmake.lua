package("nghttp2")
    set_homepage("http://nghttp2.org/")
    set_description("nghttp2 is an implementation of HTTP/2 and its header compression algorithm HPACK in C.")
    set_license("MIT")

    add_urls("https://github.com/nghttp2/nghttp2/releases/download/v$(version)/nghttp2-$(version).tar.gz")
    add_versions("1.60.0", "ca2333c13d1af451af68de3bd13462de7e9a0868f0273dea3da5bc53ad70b379")
    add_versions("1.59.0", "90fd27685120404544e96a60ed40398a3457102840c38e7215dc6dec8684470f")
    add_versions("1.58.0", "9ebdfbfbca164ef72bdf5fd2a94a4e6dfb54ec39d2ef249aeb750a91ae361dfb")
    add_versions("1.46.0", "4b6d11c85f2638531d1327fe1ed28c1e386144e8841176c04153ed32a4878208")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load("windows", function (package)
        package:add("defines", "ssize_t=int")
        if not package:config("shared") then
            package:add("defines", "NGHTTP2_STATICLIB")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(doc)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})

        local configs = {"-DENABLE_LIB_ONLY=ON", "-DENABLE_APP=OFF", "-DENABLE_DOC=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nghttp2_version", {includes = "nghttp2/nghttp2.h"}))
    end)
