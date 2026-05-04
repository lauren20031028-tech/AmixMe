package com.friendmatch.service;

import com.friendmatch.model.*;
import com.friendmatch.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SwipeService {
    private final SwipeRepository swipeRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    
    @Transactional
    public Match processSwipe(@NonNull Long swiperId, @NonNull Long swipedId, @NonNull Boolean isLike) {
        // Verificar si ya existe un swipe para evitar duplicados
        if (swipeRepository.findBySwipeIds(swiperId, swipedId).isPresent()) {
            // Si ya existe, simplemente retornar null (ya se hizo swipe antes)
            return null;
        }
        
        User swiper = userRepository.findById(swiperId).orElseThrow();
        User swiped = userRepository.findById(swipedId).orElseThrow();
        
        Swipe swipe = new Swipe();
        swipe.setSwiper(swiper);
        swipe.setSwiped(swiped);
        swipe.setIsLike(isLike);
        swipeRepository.save(swipe);
        
        if (isLike) {
            return swipeRepository.findMutualLike(swiperId, swipedId)
                .map(mutualSwipe -> {
                    Match match = new Match();
                    match.setUser1(swiper);
                    match.setUser2(swiped);
                    return matchRepository.save(match);
                })
                .orElse(null);
        }
        return null;
    }
    
    /**
     * Obtiene los usuarios a los que el usuario les dio like (excluyendo matches)
     */
    public List<User> getLikesSentByUser(@NonNull Long userId) {
        // Obtener todos los matches del usuario
        List<Match> matches = matchRepository.findUserMatches(userId);
        Set<Long> matchedUserIds = matches.stream()
            .flatMap(m -> {
                Long otherId = m.getUser1().getId().equals(userId) 
                    ? m.getUser2().getId() 
                    : m.getUser1().getId();
                return java.util.stream.Stream.of(otherId);
            })
            .collect(Collectors.toSet());
        
        // Obtener likes enviados y filtrar los que ya son matches
        return swipeRepository.findLikesSentByUser(userId)
            .stream()
            .map(Swipe::getSwiped)
            .filter(user -> !matchedUserIds.contains(user.getId()))
            .collect(Collectors.toList());
    }
    
    /**
     * Obtiene los usuarios que le dieron like al usuario (excluyendo matches)
     */
    public List<User> getLikesReceivedByUser(@NonNull Long userId) {
        // Obtener todos los matches del usuario
        List<Match> matches = matchRepository.findUserMatches(userId);
        Set<Long> matchedUserIds = matches.stream()
            .flatMap(m -> {
                Long otherId = m.getUser1().getId().equals(userId) 
                    ? m.getUser2().getId() 
                    : m.getUser1().getId();
                return java.util.stream.Stream.of(otherId);
            })
            .collect(Collectors.toSet());
        
        // Obtener likes recibidos y filtrar los que ya son matches
        return swipeRepository.findLikesReceivedByUser(userId)
            .stream()
            .map(Swipe::getSwiper)
            .filter(user -> !matchedUserIds.contains(user.getId()))
            .collect(Collectors.toList());
    }
}
