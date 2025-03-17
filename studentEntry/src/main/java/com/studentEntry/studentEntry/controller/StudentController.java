package com.studentEntry.studentEntry.controller;

import com.studentEntry.studentEntry.entity.Student;
import com.studentEntry.studentEntry.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("students")
public class StudentController {

    @Autowired
    public StudentService studentService;

    @GetMapping("get/all")
    public List<Student> getStudents(){
        return studentService.getAllStudents();
    }

    @PostMapping("/add")
    public Student addStudent(@Validated @RequestBody Student student){
        return studentService.addStudent(student);
    }
}
