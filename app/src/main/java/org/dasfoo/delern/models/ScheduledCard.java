package org.dasfoo.delern.models;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by katarina on 2/20/17.
 */

@SuppressWarnings({"checkstyle:MemberName", "checkstyle:HiddenField"})
public class ScheduledCard {

    @Exclude
    private static final String LEARNING = "learning";
    @Exclude
    private static final String REPEAT_AT_FIELD = "repeatAt";
    @Exclude
    private static final String LEVEL_FIELD = "level";
    @Exclude
    private String cId;
    private String level;
    private long repeatAt;

    /**
     * Default constructor.
     * Empty constructor is needed for casting DataSnaphot to current class.
     */
    public ScheduledCard() {
        // Empty constructor is needed for casting DataSnaphot to current class.
    }

    /**
     * Constructor for scheduling next learning for card.
     *
     * @param level level of card.
     * @param repeatAt time for the next repetition.
     */
    public ScheduledCard(final String level, final long repeatAt) {
        this.level = level;
        this.repeatAt = repeatAt;
    }

    /**
     * Gets reference to learning cards in Firebase. It is learning/userId/
     *
     * @return reference to cards.
     */
    @Exclude
    public static DatabaseReference getFirebaseScheduledCardRef() {
        return FirebaseDatabase.getInstance().getReference()
                .child(LEARNING).child(User.getCurrentUser().getUid());
        //databaseReference.keepSynced(true);
    }

    /**
     * Writes schedule for card for the next repetition.
     *
     * @param deckId id of deck.
     * @param cardId id of card.
     * @param scheduledCard schedule for card to repeat.
     */
    @Exclude
    public static void writeScheduleForCard(final String deckId, final String cardId,
                                            final ScheduledCard scheduledCard) {
        DatabaseReference databaseReference = getFirebaseScheduledCardRef();
        // TODO(ksheremet): Remove cardId.
        databaseReference.child(deckId).child(cardId).setValue(scheduledCard);
    }

    /**
     * Method gets all cards to repeat calculating current time im milliseconds.
     *
     * @param deckId deck ID where to get cards.
     * @return query of cards to repeat.
     */
    @Exclude
    public static Query fetchCardsFromDeckToRepeat(final String deckId) {
        long time = System.currentTimeMillis();
        return getFirebaseScheduledCardRef()
                .child(deckId)
                .orderByChild(REPEAT_AT_FIELD)
                .endAt(time);
    }

    /**
     * Gets requested amount of cards for learning.
     *
     * @param deckId id of deck.
     * @param limit number of cards.
     * @return query requested amount of card.
     */
    @Exclude
    public static Query fetchCardsToRepeatWithLimit(final String deckId, final int limit) {
        return fetchCardsFromDeckToRepeat(deckId).limitToFirst(limit);
    }

    /**
     * Deletes repetition schedule for all cards in given deck.
     *
     * @param deckId Id of deck.
     */
    @Exclude
    public static void deleteCardsByDeckId(final String deckId) {
        //TODO(ksheremet): Add listeners on success and failure
        getFirebaseScheduledCardRef().child(deckId).removeValue();
    }

    /**
     * Deletes repetition schedule for card from deck.
     *
     * @param deckId id of deck.
     * @param cardId id of card.
     */
    @Exclude
    public static void deleteCardbyId(final String deckId, final String cardId) {
        //TODO(ksheremet): Add listeners on success and failure
        getFirebaseScheduledCardRef().child(deckId).child(cardId).removeValue();
    }

    /**
     * Updates scheduledCard using deck ID. Card ID is the same.
     *
     * @param scheduledCard new card
     * @param deckId        deck ID where to update card.
     */
    @SuppressWarnings("PMD.UseConcurrentHashMap")
    @Exclude
    public static void updateCard(final ScheduledCard scheduledCard, final String deckId) {
        Map<String, Object> childUpdates = new HashMap<>();
        childUpdates.put(LEVEL_FIELD, scheduledCard.getLevel());
        childUpdates.put(REPEAT_AT_FIELD, scheduledCard.getRepeatAt());
        getFirebaseScheduledCardRef()
                .child(deckId)
                .child(scheduledCard.getcId())
                .updateChildren(childUpdates);
    }

    /**
     * Gets card Id.
     *
     * @return id of card.
     */
    public String getcId() {
        return cId;
    }

    /**
     * Sets card Id.
     *
     * @param cId id of card.
     */
    public void setcId(final String cId) {
        this.cId = cId;
    }

    /**
     * Gets level of card.
     *
     * @return level of card.
     */
    public String getLevel() {
        return level;
    }

    /**
     * Sets level of card.
     *
     * @param level level of card.
     */
    public void setLevel(final String level) {
        this.level = level;
    }

    /**
     * Gets the next time for card to repeat.
     *
     * @return time for the next repeating card
     */
    public long getRepeatAt() {
        return repeatAt;
    }

    /**
     * Sets the next time for card to repeat.
     *
     * @param repeatAt time for the next repeating card.
     */
    public void setRepeatAt(final long repeatAt) {
        this.repeatAt = repeatAt;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return "ScheduledCard{" +
                "cId='" + cId + '\'' +
                ", level='" + level + '\'' +
                ", repeatAt=" + repeatAt +
                '}';
    }
}