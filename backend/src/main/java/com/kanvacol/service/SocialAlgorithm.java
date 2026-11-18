package com.kanvacol.service;

import com.kanvacol.Entity.Canvas;
import com.kanvacol.Entity.CanvasRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class SocialAlgorithm {

    public int votes_count;
    public int upvotes_count;
    public int downvotes_count;

    public StringBuilder comments = new StringBuilder();
    ArrayList<Canvas> canvases = new ArrayList<Canvas>();
    @Autowired
    private final CanvasRepository repo;

    public SocialAlgorithm(CanvasRepository repo) {
        this.repo = repo;
    }

    public void publishCanvas(Canvas userCanvas, int votes_count, int upvotes_count,
                              int downvotes_count, StringBuilder comments) {
        repo.save(userCanvas);

    }

    public void createDraft(Canvas userCanvas, int votes_count, int upvotes_count,
                            int downvotes_count, StringBuilder comments) {


    }
}










