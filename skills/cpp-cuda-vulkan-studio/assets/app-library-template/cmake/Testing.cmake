include(CTest)

function(project_add_labeled_test test_name command_target labels)
    add_test(NAME "${test_name}" COMMAND "${command_target}")
    set_tests_properties("${test_name}" PROPERTIES LABELS "${labels}")
endfunction()
