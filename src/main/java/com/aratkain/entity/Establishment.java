package com.aratkain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "establishments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Establishment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "establishment_id")
    private Long establishmentId;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "estab_type", length = 50)
    private String estabType;

    @Column(length = 20)
    private String phone;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(length = 100)
    private String city;

    @Column(name = "average_rating")
    private Double averageRating;

    @Column(name = "review_count")
    private Integer reviewCount;

    @Column(name = "is_open")
    private Boolean isOpen;

    // ── NEW: URL pointing to the establishment's cover photo ──
    // Store a full URL (e.g. from Supabase Storage, S3, or Cloudinary).
    // Run the migration below before deploying:
    //   ALTER TABLE establishments ADD COLUMN photo_url TEXT;
    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @OneToOne(mappedBy = "establishment",
            cascade = CascadeType.ALL,
            fetch = FetchType.EAGER)
    private Location location;
}