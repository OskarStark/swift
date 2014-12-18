// RUN: rm -rf %t && cp -r %S/Inputs/bindings-build-record/ %t
// RUN: touch -t 201401240005 %t/*

// RUN: cd %t && %swiftc_driver -driver-print-bindings ./main.swift ./other.swift ./yet-another.swift -incremental -output-file-map %t/output.json 2>&1 | FileCheck %s -check-prefix=MUST-EXEC

// MUST-EXEC: inputs: ["./main.swift"], output: {{[{].*[}]$}}
// MUST-EXEC: inputs: ["./other.swift"], output: {{[{].*[}]$}}
// MUST-EXEC: inputs: ["./yet-another.swift"], output: {{[{].*[}]$}}

// RUN: cd %t && touch ./main.o ./other.o ./yet-another.o
// RUN: cd %t && %swiftc_driver -driver-print-bindings ./main.swift ./other.swift ./yet-another.swift -incremental -output-file-map %t/output.json 2>&1 | FileCheck %s -check-prefix=NO-EXEC

// NO-EXEC: inputs: ["./main.swift"], output: {{[{].*[}]}}, condition: check-dependencies
// NO-EXEC: inputs: ["./other.swift"], output: {{[{].*[}]}}, condition: check-dependencies
// NO-EXEC: inputs: ["./yet-another.swift"], output: {{[{].*[}]}}, condition: check-dependencies


// RUN: echo '["./main.swift", !private "./other.swift", !dirty "./yet-another.swift"]' > %t/main~buildrecord.swiftdeps
// RUN: cd %t && %swiftc_driver -driver-print-bindings ./main.swift ./other.swift ./yet-another.swift -incremental -output-file-map %t/output.json 2>&1 | FileCheck %s -check-prefix=BUILD-RECORD

// BUILD-RECORD: inputs: ["./main.swift"], output: {{[{].*[}]}}, condition: check-dependencies{{$}}
// BUILD-RECORD: inputs: ["./other.swift"], output: {{[{].*[}]}}, condition: run-without-cascading{{$}}
// BUILD-RECORD: inputs: ["./yet-another.swift"], output: {{[{].*[}]$}}

// RUN: rm %t/main.o
// RUN: cd %t && %swiftc_driver -driver-print-bindings ./main.swift ./other.swift ./yet-another.swift -incremental -output-file-map %t/output.json 2>&1 | FileCheck %s -check-prefix=BUILD-RECORD-PLUS-CHANGE
// BUILD-RECORD-PLUS-CHANGE: inputs: ["./main.swift"], output: {{[{].*[}]$}}
// BUILD-RECORD-PLUS-CHANGE: inputs: ["./other.swift"], output: {{[{].*[}]}}, condition: run-without-cascading{{$}}
// BUILD-RECORD-PLUS-CHANGE: inputs: ["./yet-another.swift"], output: {{[{].*[}]$}}

// RUN: touch %t/main.o
// RUN: cd %t && %swiftc_driver -driver-print-bindings ./main.swift ./other.swift -incremental -output-file-map %t/output.json 2>&1 | FileCheck %s -check-prefix=FILE-REMOVED
// FILE-REMOVED: inputs: ["./main.swift"], output: {{[{].*[}]$}}
// FILE-REMOVED: inputs: ["./other.swift"], output: {{[{].*[}]$}}
// FILE-REMOVED-NOT: yet-another.swift

