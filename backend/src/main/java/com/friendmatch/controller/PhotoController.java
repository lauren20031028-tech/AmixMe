package com.friendmatch.controller;

import com.friendmatch.model.UserPhoto;
import com.friendmatch.service.PhotoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/photos")
@RequiredArgsConstructor
public class PhotoController {
    private final PhotoService photoService;
    
    @PostMapping("/upload/{userId}")
    public ResponseEntity<UserPhoto> uploadPhoto(
            @PathVariable @NonNull Long userId,
            @RequestParam("file") @NonNull MultipartFile file,
            @RequestParam("order") @NonNull Integer photoOrder,
            HttpServletRequest request) {
        
        System.out.println("=== PHOTO UPLOAD DEBUG ===");
        System.out.println("UserId: " + userId);
        System.out.println("PhotoOrder: " + photoOrder);
        System.out.println("File name: " + file.getOriginalFilename());
        System.out.println("File size: " + file.getSize());
        System.out.println("Content type: " + file.getContentType());
        System.out.println("Is empty: " + file.isEmpty());
        System.out.println("Authorization header: " + request.getHeader("Authorization"));
        System.out.println("Content-Type header: " + request.getHeader("Content-Type"));
        System.out.println("User-Agent: " + request.getHeader("User-Agent"));
        
        try {
            // Validar archivo
            if (file.isEmpty()) {
                System.out.println("ERROR: File is empty");
                return ResponseEntity.badRequest().build();
            }
            
            // Validar tipo de archivo
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                System.out.println("ERROR: Invalid content type: " + contentType);
                return ResponseEntity.badRequest().build();
            }
            
            System.out.println("Calling photoService.uploadPhoto...");
            UserPhoto photo = photoService.uploadPhoto(userId, file, photoOrder);
            System.out.println("Upload successful: " + photo.getId());
            return ResponseEntity.ok(photo);
            
        } catch (IllegalStateException e) {
            System.out.println("ERROR: IllegalStateException: " + e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (IllegalArgumentException e) {
            System.out.println("ERROR: IllegalArgumentException: " + e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (IOException e) {
            System.out.println("ERROR: IOException: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        } catch (Exception e) {
            System.out.println("ERROR: Unexpected exception: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<UserPhoto>> getUserPhotos(@PathVariable @NonNull Long userId) {
        List<UserPhoto> photos = photoService.getUserPhotos(userId);
        return ResponseEntity.ok(photos);
    }
    
    @DeleteMapping("/user/{userId}/order/{photoOrder}")
    public ResponseEntity<Void> deletePhoto(
            @PathVariable @NonNull Long userId,
            @PathVariable @NonNull Integer photoOrder) {
        try {
            photoService.deletePhoto(userId, photoOrder);
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{filename}")
    public ResponseEntity<byte[]> getPhoto(@PathVariable @NonNull String filename) {
        try {
            byte[] photoData = photoService.getPhotoFile(filename);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(photoData.length);
            
            return new ResponseEntity<>(photoData, headers, HttpStatus.OK);
            
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/user/{userId}/validation")
    public ResponseEntity<Boolean> validateMinimumPhotos(@PathVariable @NonNull Long userId) {
        boolean hasMinimum = photoService.hasMinimumPhotos(userId);
        return ResponseEntity.ok(hasMinimum);
    }
}