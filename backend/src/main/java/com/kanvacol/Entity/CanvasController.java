package com.kanvacol.Entity;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@RestController
@RequestMapping("/api/canvas")
public class CanvasController {

    private final CanvasRepository repo;

    public CanvasController(CanvasRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Canvas> get(@PathVariable Long id) {
        return repo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public Canvas save(@PathVariable Long id, @RequestBody Canvas body) {
        Canvas c = repo.findById(id).orElseGet(Canvas::new);
        c.setId(id);
        c.setScene(body.getScene());
        c.setUpdatedAt(Instant.now());
        return repo.save(c);
    }

}
