import React from 'react';
import { Typography, Box, Button, Grid, Card, CardContent } from '@mui/material';
import { Link } from 'react-router-dom';

const Home: React.FC = () => {
    return (
        <Box>
            <Typography variant="h3" component="h1" gutterBottom align="center">
                Welcome to Dev-PyNode
            </Typography>
            <Typography variant="h6" component="p" gutterBottom align="center" color="text.secondary">
                AI-powered development platform with Node.js and Python backend
            </Typography>

            <Grid container spacing={3} sx={{ mt: 4 }}>
                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography variant="h5" component="h2" gutterBottom>
                                AI Chat
                            </Typography>
                            <Typography variant="body2" color="text.secondary" paragraph>
                                Interact with AI models including GPT-4 and local models like Llama2.
                            </Typography>
                            <Button component={Link} to="/chat" variant="contained" fullWidth>
                                Start Chatting
                            </Button>
                        </CardContent>
                    </Card>
                </Grid>

                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography variant="h5" component="h2" gutterBottom>
                                File Management
                            </Typography>
                            <Typography variant="body2" color="text.secondary" paragraph>
                                Upload, manage, and share files with built-in storage.
                            </Typography>
                            <Button component={Link} to="/files" variant="contained" fullWidth>
                                Manage Files
                            </Button>
                        </CardContent>
                    </Card>
                </Grid>

                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography variant="h5" component="h2" gutterBottom>
                                API Documentation
                            </Typography>
                            <Typography variant="body2" color="text.secondary" paragraph>
                                Explore the REST API with interactive documentation.
                            </Typography>
                            <Button
                                href="http://localhost:3000/docs"
                                target="_blank"
                                variant="contained"
                                fullWidth
                            >
                                View API Docs
                            </Button>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>
        </Box>
    );
};

export default Home;
