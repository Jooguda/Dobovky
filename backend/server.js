const express = require('express');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(bodyParser.json());

const SECRET_KEY = 'your_secret_key'; // Change this to your secret key

// Middleware to authenticate token
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
}

// Sample blog posts data
let posts = [];

// GET all posts
app.get('/posts', (req, res) => {
    res.json(posts);
});

// GET a single post
app.get('/posts/:id', (req, res) => {
    const post = posts.find(p => p.id === parseInt(req.params.id));
    if (!post) return res.sendStatus(404);
    res.json(post);
});

// POST a new post
app.post('/posts', authenticateToken, (req, res) => {
    const post = { id: posts.length + 1, title: req.body.title, content: req.body.content };
    posts.push(post);
    res.status(201).json(post);
});

// PUT update a post
app.put('/posts/:id', authenticateToken, (req, res) => {
    const post = posts.find(p => p.id === parseInt(req.params.id));
    if (!post) return res.sendStatus(404);
    post.title = req.body.title;
    post.content = req.body.content;
    res.json(post);
});

// DELETE a post
app.delete('/posts/:id', authenticateToken, (req, res) => {
    const index = posts.findIndex(p => p.id === parseInt(req.params.id));
    if (index === -1) return res.sendStatus(404);
    posts.splice(index, 1);
    res.sendStatus(204);
});

// Admin login endpoint
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    // Authentication logic here
    // For simplicity, assume admin username/password is admin/admin
    if (username === 'admin' && password === 'admin') {
        const user = { name: username };
        const token = jwt.sign(user, SECRET_KEY);
        return res.json({ token });
    }
    res.sendStatus(403);
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});