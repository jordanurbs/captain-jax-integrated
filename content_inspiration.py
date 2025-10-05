#!/usr/bin/env python3
"""
Minimal Content Inspiration System with simplified string handling
"""
import logging
import requests
import csv
import random
from datetime import datetime
import time
import json
import os

def load_tweet_templates():
    """Load tweet templates from CSV file"""
    templates = []
    try:
        with open('/root/tweet_templates.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                templates.append(row)
        logging.info("Loaded " + str(len(templates)) + " tweet templates")
    except Exception as e:
        logging.error("Error loading templates: " + str(e))
    return templates

def generate_tweets_from_idea(idea, templates, num_tweets=5):
    """Generate multiple tweets from a single idea using templates"""
    tweets = []

    # Use all templates if none are relevant
    for _ in range(num_tweets):
        template = random.choice(templates) if templates else {}
        tweet_text = template.get('Template', 'Check this out!')
        tweet_text = tweet_text.replace('{idea}', idea)
        tweet_text = tweet_text.replace('{content}', idea)

        # Ensure tweet is within length limit
        if len(tweet_text) > 280:
            tweet_text = tweet_text[:277] + '...'

        tweets.append(tweet_text)

    return tweets

def main():
    # Set up logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('/root/content_inspiration.log'),
            logging.StreamHandler()
        ]
    )

    logging.info("Minimal Content Inspiration System started")

    # Load tweet templates
    templates = load_tweet_templates()
    if not templates:
        logging.warning("No templates loaded, using default")

    # Bot configuration
    BOT_TOKEN = '8376403824:AAHIukguRIEvUOpdBFfFvAM36yXdOh_2ncw'
    CHAT_ID = '-4957554154'

    # Keywords that trigger inspiration response
    trigger_keywords = ['building', 'learned', 'challenge', 'inspiration', 'experience', 'idea', 'create', 'build', 'develop', 'learn', 'share', 'thought', 'content']

    # Track last update ID to get only new messages
    last_update_id = 0

    # Track bot's question message IDs for context (message_id -> tweets data)
    bot_question_context = {}

    while True:
        try:
            # Get updates from Telegram
            url = "https://api.telegram.org/bot" + BOT_TOKEN + "/getUpdates"
            payload = {
                'timeout': 30,
                'offset': last_update_id + 1
            }

            response = requests.get(url, params=payload)

            if response.status_code == 200:
                data = response.json()

                if data.get('ok') and data.get('result'):
                    # Process all messages in the batch
                    for message in data['result']:
                        message_id = message['update_id']

                        # Extract message text
                        if 'message' in message and 'text' in message['message']:
                            text = message['message']['text'].lower()
                            user_message = message['message']

                            # Check if this is a reply to bot's question
                            is_reply_to_bot = 'reply_to_message' in user_message and user_message['reply_to_message'].get('from', {}).get('is_bot', False)

                            # Check if message contains trigger keywords
                            if any(keyword in text for keyword in trigger_keywords):
                                idea = message['message']['text']
                                logging.info("Received inspiration idea: " + idea)

                                # Generate tweets from the idea
                                tweets = generate_tweets_from_idea(idea, templates, num_tweets=3)

                                # Create response data
                                response_data = {
                                    'idea': idea,
                                    'generated_tweets': tweets,
                                    'timestamp': datetime.now().isoformat(),
                                    'source': 'telegram_message'
                                }

                                # Save to knowledge directory
                                knowledge_dir = '/knowledge/ai-captains/responses'
                                os.makedirs(knowledge_dir, exist_ok=True)

                                # Create filename with date
                                date_str = datetime.now().strftime('%Y-%m-%d')
                                response_file = knowledge_dir + '/inspiration-' + date_str + '.json'

                                # Save the response
                                with open(response_file, 'w') as f:
                                    json.dump(response_data, f, indent=2)

                                logging.info('Saved inspiration response to ' + response_file)

                                # Create response message with simple string operations
                                response_message = "Here are some tweet ideas based on your idea: " + idea + "\n\n"

                                for i, tweet in enumerate(tweets, 1):
                                    response_message += str(i) + ". " + tweet + "\n\n"

                                response_message += "Which one is your favorite?"

                                # Send message to Telegram
                                send_url = "https://api.telegram.org/bot" + BOT_TOKEN + "/sendMessage"
                                send_payload = {
                                    'chat_id': CHAT_ID,
                                    'text': response_message
                                }

                                try:
                                    send_response = requests.post(send_url, json=send_payload)
                                    if send_response.status_code == 200:
                                        logging.info("Response sent to Telegram")
                                        # Store bot's message ID and context for tracking replies
                                        bot_msg_id = send_response.json().get('result', {}).get('message_id')
                                        if bot_msg_id:
                                            bot_question_context[bot_msg_id] = {
                                                'tweets': tweets,
                                                'idea': idea
                                            }
                                    else:
                                        logging.error("Failed to send response: " + str(send_response.text))
                                except Exception as e:
                                    logging.error("Error sending response: " + str(e))

                            # Handle user's reply to bot's question
                            elif is_reply_to_bot:
                                replied_msg_id = user_message['reply_to_message'].get('message_id')
                                if replied_msg_id in bot_question_context:
                                    # User is responding to "Which one is your favorite?"
                                    context = bot_question_context[replied_msg_id]
                                    user_choice = text

                                    logging.info("User responded with choice: " + user_choice)

                                    # Try to extract tweet number from response
                                    tweet_number = None
                                    for num in ['1', '2', '3', 'first', 'second', 'third']:
                                        if num in user_choice:
                                            if num == 'first' or num == '1':
                                                tweet_number = 0
                                            elif num == 'second' or num == '2':
                                                tweet_number = 1
                                            elif num == 'third' or num == '3':
                                                tweet_number = 2
                                            break

                                    if tweet_number is not None and tweet_number < len(context['tweets']):
                                        selected_tweet = context['tweets'][tweet_number]

                                        # Save user's choice
                                        choice_data = {
                                            'idea': context['idea'],
                                            'selected_tweet': selected_tweet,
                                            'all_tweets': context['tweets'],
                                            'user_choice': user_choice,
                                            'timestamp': datetime.now().isoformat(),
                                            'source': 'telegram_reply'
                                        }

                                        knowledge_dir = '/knowledge/ai-captains/responses'
                                        os.makedirs(knowledge_dir, exist_ok=True)
                                        date_str = datetime.now().strftime('%Y-%m-%d')
                                        choice_file = knowledge_dir + '/choice-' + date_str + '.json'

                                        with open(choice_file, 'w') as f:
                                            json.dump(choice_data, f, indent=2)

                                        logging.info('Saved user choice to ' + choice_file)

                                        # Confirm to user
                                        confirm_msg = "Great choice! Your selected tweet:\n\n" + selected_tweet + "\n\nI've saved this for you!"
                                        confirm_payload = {
                                            'chat_id': CHAT_ID,
                                            'text': confirm_msg,
                                            'reply_to_message_id': user_message['message_id']
                                        }

                                        try:
                                            requests.post(send_url, json=confirm_payload)
                                            logging.info("Confirmation sent to user")
                                            # Clean up context
                                            del bot_question_context[replied_msg_id]
                                        except Exception as e:
                                            logging.error("Error sending confirmation: " + str(e))
                                    else:
                                        # Unclear response
                                        unclear_msg = "I'm not sure which one you meant. Please reply with 1, 2, or 3."
                                        unclear_payload = {
                                            'chat_id': CHAT_ID,
                                            'text': unclear_msg,
                                            'reply_to_message_id': user_message['message_id']
                                        }

                                        try:
                                            requests.post(send_url, json=unclear_payload)
                                        except Exception as e:
                                            logging.error("Error sending unclear message: " + str(e))

                        # Update last_update_id to mark this message as processed
                        last_update_id = max(last_update_id, message_id)

            # Wait before checking for new messages
            time.sleep(5)

        except Exception as e:
            logging.error("Error in main loop: " + str(e))
            time.sleep(10)

if __name__ == "__main__":
    main()
