package com.kanvacol.Entity;

import com.kanvacol.Enums.ProfileVisibility;
import com.kanvacol.Enums.Roles;
import jakarta.persistence.*;

import java.util.UUID;

@Entity
@Table(name = "users")

public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private String email;
    private String userName;
    private String firstName;
    private String lastName;
    private String createdAt;
    private String updatedAt;
    private String passwordHash;
    private String googleId;
    @Enumerated(EnumType.STRING)
    private Roles role;
    @Enumerated(EnumType.STRING)
    ProfileVisibility profileVisibility;

}
