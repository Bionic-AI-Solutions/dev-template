import React, { useState } from 'react';
import { Typography, Box, Button, Paper, List, ListItem, ListItemText, ListItemIcon } from '@mui/material';
import { CloudUpload, Description } from '@mui/icons-material';

const Files: React.FC = () => {
    const [files] = useState([
        { id: 1, name: 'example.txt', size: '1.2 KB', date: '2024-01-15' },
        { id: 2, name: 'document.pdf', size: '2.5 MB', date: '2024-01-14' },
    ]);

    return (
        <Box>
            <Typography variant="h4" component="h1" gutterBottom>
                File Management
            </Typography>

            <Paper sx={{ p: 2, mb: 2 }}>
                <Button
                    variant="contained"
                    startIcon={<CloudUpload />}
                    component="label"
                >
                    Upload File
                    <input type="file" hidden />
                </Button>
            </Paper>

            <Paper>
                <List>
                    {files.map((file) => (
                        <ListItem key={file.id} divider>
                            <ListItemIcon>
                                <Description />
                            </ListItemIcon>
                            <ListItemText
                                primary={file.name}
                                secondary={`${file.size} • ${file.date}`}
                            />
                        </ListItem>
                    ))}
                </List>
            </Paper>
        </Box>
    );
};

export default Files;
