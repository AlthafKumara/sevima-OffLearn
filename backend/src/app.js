import "dotenv/config"

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import profileRoute from './routes/profileRoute.js';
import subjectRoute from './routes/subjectRoute.js';
import moduleRoute from './routes/moduleRoute.js';
import quizRoute from './routes/quizRoute.js';
import quizQuestionRoute from './routes/quizQuestionRoute.js';
import quizOptionRoute from './routes/quizOptionRoute.js';
import quizAttemptRoute from './routes/quizAttemptRoute.js';
import studentProgressRoute from './routes/studentProgressRoute.js';
import syncRoute from './routes/syncRoute.js';

const app = express();

// Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// Basic Route
app.get('/', (req, res) => {
  res.json({ success: true, message: 'Welcome to Offlearn API' });
});

// Routes
app.use('/profiles', profileRoute);
app.use('/subjects', subjectRoute);
app.use('/modules', moduleRoute);
app.use('/quizzes', quizRoute);
app.use('/quiz-questions', quizQuestionRoute);
app.use('/quiz-options', quizOptionRoute);
app.use('/quiz-attempts', quizAttemptRoute);
app.use('/student-progress', studentProgressRoute);
app.use('/sync', syncRoute); // Although not a table, sync is a specific batch feature handler

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Something went wrong!' });
});

export default app;
