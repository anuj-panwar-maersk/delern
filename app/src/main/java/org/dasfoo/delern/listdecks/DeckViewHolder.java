/*
 * Copyright (C) 2017 Katarina Sheremet
 * This file is part of Delern.
 *
 * Delern is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Delern is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with  Delern.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.dasfoo.delern.listdecks;

import android.support.v7.widget.RecyclerView;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import org.dasfoo.delern.R;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * Created by Katarina Sheremet on 9/22/16 1:11 AM.
 * Provide a reference to the views for each data item
 * Complex data items may need more than one view per item, and
 * you provide access to all the views for a data item in a view holder
 */

public class DeckViewHolder extends RecyclerView.ViewHolder implements
        PopupMenu.OnMenuItemClickListener {

    private static final Logger LOGGER = LoggerFactory.getLogger(DeckViewHolder.class);
    private static final String NULL_CARDS = "0";

    @BindView(R.id.deck_text_view)
    /* default */ TextView mDeckTextView;
    @BindView(R.id.count_to_learn_textview)
    /* default */ TextView mCountToLearnTextView;
    private OnDeckViewHolderClick mOnViewClick;
    private String mCheckedDeckType;

    /**
     * Constructor. It initializes variable that describe how to place deck.
     *
     * @param viewHolder item view
     */
    public DeckViewHolder(final View viewHolder) {
        super(viewHolder);
        ButterKnife.bind(this, viewHolder);
    }

    /**
     * Getter to reference to R.id.deck_text_view.
     *
     * @return textview of deck
     */
    public TextView getDeckTextView() {
        return mDeckTextView;
    }

    /**
     * Getter for number of cards to learn. mCountToLearnTextView references to
     * R.id.count_to_learn_textview.
     *
     * @return textview with number of cards to learn
     */
    public TextView getCountToLearnTextView() {
        return mCountToLearnTextView;
    }

    /**
     * Setter for mOnViewClick. It listeners clicks on deck name and
     * popup menu.
     *
     * @param onViewClick onDeckViewClickListener
     */
    public void setOnViewClick(final OnDeckViewHolderClick onViewClick) {
        this.mOnViewClick = onViewClick;
    }

    @OnClick(R.id.deck_view_holder)
    /* default */ void onDeckClick(final View view) {
        // if number of cards is 0, show message to user
        String cardCount = mCountToLearnTextView.getText().toString();
        if (NULL_CARDS.equals(cardCount)) {
            Toast.makeText(view.getContext(), R.string.no_card_message,
                    Toast.LENGTH_SHORT).show();
        } else {
            int position = getAdapterPosition();
            if (position != RecyclerView.NO_POSITION) {
                mOnViewClick.learnDeck(position);
            }
        }
    }

    /**
     * Method shows Popup menu on chosen deck menu.
     * Access to method is package-private due to ButterKnife
     *
     * @param v clicked view
     */
    @OnClick(R.id.deck_popup_menu)
    /* default */ void showPopup(final View v) {
        PopupMenu popup = new PopupMenu(v.getContext(), v);
        popup.setOnMenuItemClickListener(this);
        MenuInflater inflater = popup.getMenuInflater();
        inflater.inflate(R.menu.deck_menu, popup.getMenu());
        popup.show();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean onMenuItemClick(final MenuItem item) {

        int position = getAdapterPosition();
        if (position == RecyclerView.NO_POSITION) {
            // ViewHolder was either removed or the view has been changed.
            // Rather than failing, ignore the click.
            return false;
        }
        switch (item.getItemId()) {
            case R.id.edit_deck_menu:
                mOnViewClick.editDeck(position);
                return true;
            case R.id.deck_settings:
                mOnViewClick.editDeckSettings(position);
                return true;
            default:
                LOGGER.info("Menu Item {} is not implemented yet", item.getItemId());
                return false;
        }
    }

    /**
     * Setter for deck type.
     *
     * @param checkedDeckType deck type
     */
    public void setDeckCardType(final String checkedDeckType) {
        this.mCheckedDeckType = checkedDeckType;
    }
}
