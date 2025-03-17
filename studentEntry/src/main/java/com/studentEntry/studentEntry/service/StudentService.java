package com.studentEntry.studentEntry.service;


import com.studentEntry.studentEntry.entity.Student;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface StudentService {

    List<Student> getAllStudents();

    Student addStudent(Student student);

}
