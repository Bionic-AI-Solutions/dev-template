import React, { useState } from 'react';
import { Typography, Box, TextField, Button, Paper, List, ListItem, ListItemText } from '@mui/material';

const Chat: React.FC = () => {
    const [message, setMessage] = useState('');
    const [messages, setMessages] = useState<Array<{ id: number, text: string, isUser: boolean }>>([]);

    const handleSendMessage = () => {
        if (message.trim()) {
            const newMessage = {
                id: Date.now(),
                text: message,
                isUser: true
            };
            setMessages(prev => [...prev, newMessage]);
            setMessage('');

            // Simulate AI response
            setTimeout(() => {
                const aiResponse = {
                    id: Date.now() + 1,
                    text: `AI Response to: "${message}"`,
                    isUser: false
                };
                setMessages(prev => [...prev, aiResponse]);
            }, 1000);
        }
    };

    return (
        <Box>
            <Typography variant="h4" component="h1" gutterBottom>
                AI Chat
            </Typography>

            <Paper sx={{ height: 400, overflow: 'auto', mb: 2, p: 2 }}>
                <List>
                    {messages.map((msg) => (
                        <ListItem key={msg.id} sx={{
                            justifyContent: msg.isUser ? 'flex-end' : 'flex-start',
                            flexDirection: msg.isUser ? 'row-reverse' : 'row'
                        }}>
                            <Paper sx={{
                                p: 1,
                                bgcolor: msg.isUser ? 'primary.main' : 'grey.200',
                                color: msg.isUser ? 'white' : 'black'
                            }}>
                                <ListItemText primary={msg.text} />
                            </Paper>
                        </ListItem>
                    ))}
                </List>
            </Paper>

            <Box sx={{ display: 'flex', gap: 1 }}>
                <TextField
                    fullWidth
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Type your message..."
                    onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                />
                <Button
                    variant="contained"
                    onClick={handleSendMessage}
                    disabled={!message.trim()}
                >
                    Send
                </Button>
            </Box>
        </Box>
    );
};

export default Chat;
