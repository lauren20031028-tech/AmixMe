package com.friendmatch.service;

import com.friendmatch.model.User;
import com.friendmatch.model.UserPhoto;
import com.friendmatch.repository.UserPhotoRepository;
import com.friendmatch.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PhotoService {
    private final UserPhotoRepository userPhotoRepository;
    private final UserRepository userRepository;
    
    private static final String UPLOAD_DIR = "uploads/photos/";
    private static final int MAX_PHOTOS = 3;
    private static final int MIN_PHOTOS = 2;
    
    @Transactional
    public UserPhoto uploadPhoto(@NonNull Long userId, @NonNull MultipartFile file, @NonNull Integer photoOrder) throws IOException {
        User user = userRepository.findById(userId).orElseThrow();
        
        // Verificar límite de fotos
        Long photoCount = userPhotoRepository.countByUserId(userId);
        if (photoCount >= MAX_PHOTOS) {
            throw new IllegalStateException("Usuario ya tiene el máximo de " + MAX_PHOTOS + " fotos");
        }
        
        // Validar orden de foto
        if (photoOrder < 1 || photoOrder > MAX_PHOTOS) {
            throw new IllegalArgumentException("El orden de la foto debe estar entre 1 y " + MAX_PHOTOS);
        }
        
        // Crear directorio si no existe
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Generar nombre único para el archivo
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null ? 
            originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
        String filename = UUID.randomUUID().toString() + extension;
        
        // Guardar archivo
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath);
        
        // Crear registro en base de datos
        UserPhoto userPhoto = new UserPhoto();
        userPhoto.setUser(user);
        userPhoto.setPhotoUrl("/api/photos/" + filename);
        userPhoto.setPhotoOrder(photoOrder);
        userPhoto.setIsPrimary(photoOrder == 1); // La primera foto es la principal
        
        return userPhotoRepository.save(userPhoto);
    }
    
    public List<UserPhoto> getUserPhotos(@NonNull Long userId) {
        return userPhotoRepository.findByUserIdOrderByPhotoOrder(userId);
    }
    
    @Transactional
    public void deletePhoto(@NonNull Long userId, @NonNull Integer photoOrder) {
        List<UserPhoto> photos = userPhotoRepository.findByUserIdOrderByPhotoOrder(userId);
        
        // Verificar que no se eliminen fotos si quedarían menos del mínimo
        if (photos.size() <= MIN_PHOTOS) {
            throw new IllegalStateException("No se puede eliminar la foto. Mínimo " + MIN_PHOTOS + " fotos requeridas");
        }
        
        userPhotoRepository.deleteByUserIdAndPhotoOrder(userId, photoOrder);
        
        // Reordenar fotos restantes
        reorderPhotos(userId);
    }
    
    @Transactional
    public void reorderPhotos(@NonNull Long userId) {
        List<UserPhoto> photos = userPhotoRepository.findByUserIdOrderByPhotoOrder(userId);
        
        for (int i = 0; i < photos.size(); i++) {
            UserPhoto photo = photos.get(i);
            photo.setPhotoOrder(i + 1);
            photo.setIsPrimary(i == 0); // La primera siempre es principal
            userPhotoRepository.save(photo);
        }
    }
    
    public boolean hasMinimumPhotos(@NonNull Long userId) {
        Long photoCount = userPhotoRepository.countByUserId(userId);
        return photoCount >= MIN_PHOTOS;
    }
    
    public byte[] getPhotoFile(@NonNull String filename) throws IOException {
        Path filePath = Paths.get(UPLOAD_DIR).resolve(filename);
        if (!Files.exists(filePath)) {
            throw new IOException("Archivo no encontrado: " + filename);
        }
        return Files.readAllBytes(filePath);
    }
}