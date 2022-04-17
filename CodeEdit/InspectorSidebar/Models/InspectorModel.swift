//
//  InspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/17.
//

import SwiftUI

public class InspectorModel: ObservableObject {

    public static let shared: InspectorModel = .init()

    @Published
    var languageTypeObjCList = [LanguageType(name: "Objective-C Preprocessed Source", id: "obj_c_pre_source"),
                                LanguageType(name: "Objective-C Source", id: "m"),
                                LanguageType(name: "Objective-C++ Preprocessed Source", id: "obj_c_++_pre_source"),
                                LanguageType(name: "Objective-C++ Source", id: "m")]

    @Published
    var sourcecodeCList = [LanguageType(name: "C Header", id: "h"),
                           LanguageType(name: "C Preprocessed Source", id: "obj_c_source"),
                           LanguageType(name: "C Source", id: "c")]

    @Published
    var sourcecodeCPlusList = [LanguageType(name: "C++ Header", id: "hh"),
                               LanguageType(name: "C++ Preprocessed Source", id: "i"),
                               LanguageType(name: "C++ Source", id: "cpp")]

    @Published
    var sourcecodeSwiftList = [LanguageType(name: "Swift Source", id: "swift")]

    @Published
    var sourcecodeAssemblyList = [LanguageType(name: "Assembly", id: "asm"),
                                  LanguageType(name: "LLVM Assembly", id: "obj_c_source"),
                                  LanguageType(name: "NASM Assembly", id: "obj_c_++_pre_source"),
                                  LanguageType(name: "PPC Assembly", id: "obj_c_++_source")]

    @Published
    var sourcecodeScriptList = [LanguageType(name: "AppleScript Uncompiled Source", id: "obj_c_pre_source"),
                                LanguageType(name: "JavaScript Source", id: "js"),
                                LanguageType(name: "PHP Script", id: "php"),
                                LanguageType(name: "Perl Script", id: "pl"),
                                LanguageType(name: "Python Script", id: "py"),
                                LanguageType(name: "Ruby Script", id: "rb")]

    @Published
    var sourcecodeVariousList = [LanguageType(name: "Ada Source", id: "obj_c_pre_source"),
                                 LanguageType(name: "CLIPS Source", id: "obj_c_source"),
                                 LanguageType(name: "DTrace Source", id: "obj_c_++_pre_source"),
                                 LanguageType(name: "Fortran 77 Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Fortran 90 Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Fortran Source", id: "obj_c_++_source"),
                                 LanguageType(name: "lig Source", id: "obj_c_++_source"),
                                 LanguageType(name: "JAM Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Java Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Lex Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Metal Shader Source", id: "obj_c_++_source"),
                                 LanguageType(name: "MiG Source", id: "obj_c_++_source"),
                                 LanguageType(name: "OpenCL Source", id: "obj_c_++_source"),
                                 LanguageType(name: "OpenGL Shading Language Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Pascal Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Rez Source", id: "obj_c_++_source"),
                                 LanguageType(name: "Yacc Source", id: "obj_c_++_source")]

    @Published
    var propertyList = [LanguageType(name: "Info plist XML", id: "obj_c_pre_source"),
                        LanguageType(name: "Property List Binary", id: "obj_c_source"),
                        LanguageType(name: "Property List Text", id: "obj_c_++_pre_source"),
                        LanguageType(name: "Property List XML", id: "obj_c_++_source"),
                        LanguageType(name: "XML", id: "xml")]

    @Published
    var shellList = [LanguageType(name: "Bash Shell Script", id: "bash"),
                     LanguageType(name: "Shell Script", id: "sh"),
                     LanguageType(name: "CSH Shell Script", id: "csh")]

    @Published
    var machOList = [LanguageType(name: "Mach-O Core Dump", id: "obj_c_pre_source"),
                     LanguageType(name: "Mach-O Dynamic Library", id: "obj_c_source"),
                     LanguageType(name: "Mach-O FVM Library", id: "obj_c_++_pre_source"),
                     LanguageType(name: "Mach-O Object Code", id: "obj_c_++_source"),
                     LanguageType(name: "Mach-O Preload Data", id: "obj_c_++_source"),
                     LanguageType(name: "Mach-O bundle", id: "obj_c_++_source")]

    @Published
    var textList = [LanguageType(name: "Cascading Style Sheets", id: "css"),
                    LanguageType(name: "HTML", id: "html"),
                    LanguageType(name: "JSON", id: "json"),
                    LanguageType(name: "Markdown Text", id: "md"),
                    LanguageType(name: "Plain Text", id: "txt"),
                    LanguageType(name: "Rich Text Format", id: "rtf"),
                    LanguageType(name: "YAML", id: "yaml")]

    @Published
    var audioList = [LanguageType(name: "AIFF Audio", id: "aiff"),
                    LanguageType(name: "MIDI Audio", id: "midi"),
                    LanguageType(name: "MP3 Audio", id: "mp3"),
                    LanguageType(name: "WAV Audio", id: "wav"),
                    LanguageType(name: "AU Audio", id: "au")]

    @Published
    var imageList = [LanguageType(name: "BMP Image", id: "bmp"),
                    LanguageType(name: "GIF Image", id: "gif"),
                    LanguageType(name: "Icon", id: "icon"),
                    LanguageType(name: "JPEG Image", id: "jpeg"),
                    LanguageType(name: "Microsoft Icon", id: "ico"),
                    LanguageType(name: "PICT Image", id: "pict"),
                    LanguageType(name: "PNG Image", id: "png"),
                    LanguageType(name: "TIFF Image", id: "tiff")]

    @Published
    var videoList = [LanguageType(name: "AVI Video", id: "avi"),
                    LanguageType(name: "MPEG Video", id: "mpeg"),
                    LanguageType(name: "QuickTime Video", id: "quicktime")]

    @Published
    var archiveList = [LanguageType(name: "AppleScript Dictionary Archivo", id: "obj_c_pre_source"),
                       LanguageType(name: "Archive", id: "archive"),
                       LanguageType(name: "BinHex Archive", id: "obj_c_++_pre_source"),
                       LanguageType(name: "J2EE Enterprise Archive", id: "obj_c_++_source"),
                       LanguageType(name: "Java Archive", id: "obj_c_++_source"),
                       LanguageType(name: "MacBinary Archive", id: "obj_c_++_source"),
                       LanguageType(name: "PPOB Archive", id: "obj_c_++_source"),
                       LanguageType(name: "Resource Archive", id: "obj_c_++_source"),
                       LanguageType(name: "Stuffit Archive", id: "obj_c_++_source"),
                       LanguageType(name: "Web Application Archive", id: "obj_c_++_source"),
                       LanguageType(name: "Zip Archive", id: "zip"),
                       LanguageType(name: "gzip Archive", id: "gzip"),
                       LanguageType(name: "tar Archive", id: "tar")]

    @Published
    var otherList = [LanguageType(name: "API Notes", id: "obj_c_pre_source"),
                     LanguageType(name: "AppleScript Script Suite Definition", id: "obj_c_source"),
                     LanguageType(name: "AppleScript Script Terminology Definition", id: "obj_c_++_pre_source"),
                     LanguageType(name: "Data", id: "obj_c_++_source"),
                     LanguageType(name: "Exported Symbols", id: "obj_c_++_source"),
                     LanguageType(name: "Java Bundle", id: "aab"),
                     LanguageType(name: "Java Bytecode", id: "class"),
                     LanguageType(name: "LLVM Module Map", id: "obj_c_++_source"),
                     LanguageType(name: "Object Code", id: "obj_c_++_source"),
                     LanguageType(name: "PDF document", id: "pdf"),
                     LanguageType(name: "Quartz Composer Composition", id: "obj_c_++_source"),
                     LanguageType(name: "Text-Based Dynamic Library Definition", id: "obj_c_++_source"),
                     LanguageType(name: "Worksheet Script", id: "obj_c_++_source"),
                     LanguageType(name: "Makefile", id: "make")]
}
