// â”€â”€â”€ Medicos Routes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Reddit-style professional community for healthcare providers.
//
// GET  /api/medicos/feed                  â€“ paginated feed (?sort=hot|new|top|rising)
// POST /api/medicos/posts                 â€“ create post
// GET  /api/medicos/posts/:id             â€“ single post
// PUT  /api/medicos/posts/:id             â€“ update post
// DELETE /api/medicos/posts/:id           â€“ delete post
// POST /api/medicos/posts/:id/vote        â€“ vote (up|down|none)
// POST /api/medicos/posts/:id/share       â€“ increment share count
// POST /api/medicos/posts/:id/award       â€“ give award
// GET  /api/medicos/posts/:id/comments    â€“ list comments
// POST /api/medicos/posts/:id/comments    â€“ add comment
// POST /api/medicos/comments/:id/vote     â€“ vote on comment
// GET  /api/medicos/communities           â€“ communities (specialties) with member/post counts

const express   = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, param, query, validationResult } = require('express-validator');
const db = require('../db/database');

const router = express.Router();

// â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function relativeTime(iso) {
  const diff = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1)  return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24)  return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 30) return `${days}d ago`;
  const months = Math.floor(days / 30);
  return `${months}mo ago`;
}

function computeScore(p) {
  return (p.upvotes || p.likes || 0) - (p.downvotes || 0);
}

// Reddit hot algorithm
function hotScore(p) {
  const score     = computeScore(p);
  const ageHours  = (Date.now() - new Date(p.created_at).getTime()) / 3600000;
  const order     = Math.log10(Math.max(Math.abs(score), 1));
  const sign      = score > 0 ? 1 : score < 0 ? -1 : 0;
  return sign * order - ageHours / 12;
}

function risingScore(p) {
  const score    = computeScore(p);
  const ageHours = Math.max((Date.now() - new Date(p.created_at).getTime()) / 3600000, 0.5);
  return score / ageHours;
}

function formatPost(p) {
  return {
    ...p,
    score:     computeScore(p),
    timestamp: relativeTime(p.created_at),
    awards:    p.awards || [],
    flair:     p.flair  || null,
    is_pinned: p.is_pinned || false,
  };
}

function validationFail(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) { res.status(400).json({ errors: errors.array() }); return true; }
  return false;
}

// â”€â”€ GET /api/medicos/feed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// ?sort=hot(default)|new|top|rising
// ?community=Cardiology  (filter by specialty/community)
// ?limit=20&offset=0
router.get(
  '/feed',
  [
    query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
    query('offset').optional().isInt({ min: 0 }).toInt(),
    query('sort').optional().isIn(['hot', 'new', 'top', 'rising']),
    query('community').optional().isString().trim(),
    // backwards compat
    query('tab').optional().isString().trim(),
    query('specialty').optional().isString().trim(),
  ],
  (req, res) => {
    if (validationFail(req, res)) return;

    const sort      = req.query.sort || (req.query.tab === 'trending' ? 'hot' : 'new');
    const community = req.query.community || req.query.specialty || '';
    const limit     = req.query.limit  || 30;
    const offset    = req.query.offset || 0;

    let posts = db.getMedicosPosts(10000, 0);

    // community filter
    if (community) {
      const cl = community.toLowerCase();
      posts = posts.filter(p =>
        (p.specialty || '').toLowerCase() === cl ||
        (p.tags || []).some(t => t.toLowerCase().includes(cl))
      );
    }

    // sort
    switch (sort) {
      case 'new':
        posts = [...posts].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        break;
      case 'top':
        posts = [...posts].sort((a, b) => computeScore(b) - computeScore(a));
        break;
      case 'rising':
        posts = [...posts].sort((a, b) => risingScore(b) - risingScore(a));
        break;
      case 'hot':
      default:
        posts = [...posts].sort((a, b) => hotScore(b) - hotScore(a));
        break;
    }

    const total = posts.length;
    const paged = posts.slice(Number(offset), Number(offset) + Number(limit));

    return res.json({
      total,
      limit: Number(limit),
      offset: Number(offset),
      sort,
      posts: paged.map(formatPost),
    });
  }
);

// â”€â”€ POST /api/medicos/posts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post(
  '/posts',
  [
    body('author.name').notEmpty().isString().trim(),
    body('author.title').notEmpty().isString().trim(),
    body('author.image').notEmpty().isString().trim(),
    body('author.verified').optional().isBoolean(),
    body('title').notEmpty().isString().trim().isLength({ max: 300 }),
    body('body').notEmpty().isString().trim().isLength({ max: 5000 }),
    body('imageUrl').optional({ nullable: true }),
    body('tags').optional().isArray({ max: 10 }),
    body('specialty').optional({ nullable: true }).isString().trim(),
    body('flair').optional({ nullable: true }).isString().trim(),
  ],
  (req, res) => {
    if (validationFail(req, res)) return;

    const { author, title, body: bodyText, imageUrl = null, tags = [], specialty = null, flair = null } = req.body;
    const id  = uuidv4();
    const now = new Date().toISOString();

    const post = db.insertMedicosPost({
      id, author: { name: author.name, title: author.title, image: author.image, verified: author.verified ?? false },
      title, body: bodyText, imageUrl, tags, specialty, flair,
      upvotes: 1, downvotes: 0, comments: 0, shares: 0, awards: [],
      is_pinned: false, created_at: now, updated_at: now,
    });

    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ event: 'medicos_post', data: formatPost(post) });
    }
    return res.status(201).json(formatPost(post));
  }
);

// â”€â”€ GET /api/medicos/posts/:id â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/posts/:id', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  const post = db.getMedicosPost(req.params.id);
  if (!post) return res.status(404).json({ message: 'Post not found' });
  return res.json(formatPost(post));
});

// â”€â”€ PUT /api/medicos/posts/:id â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.put('/posts/:id',
  [
    param('id').notEmpty(),
    body('title').optional().isString().trim().isLength({ max: 300 }),
    body('body').optional().isString().trim().isLength({ max: 5000 }),
    body('flair').optional({ nullable: true }).isString().trim(),
    body('imageUrl').optional({ nullable: true }),
    body('tags').optional().isArray({ max: 10 }),
  ],
  (req, res) => {
    if (validationFail(req, res)) return;
    const post = db.getMedicosPost(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found' });
    const patch = {};
    ['title', 'body', 'imageUrl', 'tags', 'flair', 'specialty'].forEach(k => {
      if (req.body[k] !== undefined) patch[k] = req.body[k];
    });
    return res.json(formatPost(db.updateMedicosPost(req.params.id, patch)));
  }
);

// â”€â”€ DELETE /api/medicos/posts/:id â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.delete('/posts/:id', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  if (!db.getMedicosPost(req.params.id)) return res.status(404).json({ message: 'Post not found' });
  db.deleteMedicosPost(req.params.id);
  return res.status(204).send();
});

// â”€â”€ POST /api/medicos/posts/:id/vote â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// body: { direction: 'up' | 'down' | 'none', prev: 'up'|'down'|'none' }
router.post('/posts/:id/vote', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  const post = db.getMedicosPost(req.params.id);
  if (!post) return res.status(404).json({ message: 'Post not found' });

  const direction = req.body.direction || 'none';
  const prev      = req.body.prev      || 'none';

  let upvotes   = post.upvotes   || post.likes || 0;
  let downvotes = post.downvotes || 0;

  // undo previous vote
  if (prev === 'up')   upvotes   = Math.max(0, upvotes - 1);
  if (prev === 'down') downvotes = Math.max(0, downvotes - 1);

  // apply new vote
  if (direction === 'up')   upvotes   += 1;
  if (direction === 'down') downvotes += 1;

  db.updateMedicosPost(req.params.id, { upvotes, downvotes });
  const score = upvotes - downvotes;
  return res.json({ id: req.params.id, upvotes, downvotes, score });
});

// â”€â”€ POST /api/medicos/posts/:id/share â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/posts/:id/share', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  const post = db.getMedicosPost(req.params.id);
  if (!post) return res.status(404).json({ message: 'Post not found' });
  const shares = (post.shares || 0) + 1;
  db.updateMedicosPost(req.params.id, { shares });
  return res.json({ id: req.params.id, shares });
});

// â”€â”€ POST /api/medicos/posts/:id/award â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// body: { type: 'gold'|'silver'|'helpful'|'wholesome'|'insightful' }
router.post('/posts/:id/award', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  const post = db.getMedicosPost(req.params.id);
  if (!post) return res.status(404).json({ message: 'Post not found' });

  const type = req.body.type || 'helpful';
  const awards = [...(post.awards || [])];
  const existing = awards.find(a => a.type === type);
  if (existing) existing.count = (existing.count || 1) + 1;
  else awards.push({ type, count: 1 });

  db.updateMedicosPost(req.params.id, { awards });
  return res.json({ id: req.params.id, awards });
});

// â”€â”€ GET /api/medicos/posts/:id/comments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/posts/:id/comments',
  [param('id').notEmpty(), query('limit').optional().isInt({ min:1,max:200 }).toInt(), query('offset').optional().isInt({min:0}).toInt()],
  (req, res) => {
    if (validationFail(req, res)) return;
    if (!db.getMedicosPost(req.params.id)) return res.status(404).json({ message: 'Post not found' });
    const { limit = 50, offset = 0 } = req.query;
    const comments = db.getMedicosComments(req.params.id, Number(limit), Number(offset));
    return res.json({
      total: db.countMedicosComments(req.params.id), limit: Number(limit), offset: Number(offset),
      comments: comments.map(c => ({ ...c, score: (c.upvotes||0)-(c.downvotes||0), timestamp: relativeTime(c.created_at) })),
    });
  }
);

// â”€â”€ POST /api/medicos/posts/:id/comments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/posts/:id/comments',
  [
    param('id').notEmpty(),
    body('author.name').notEmpty().isString().trim(),
    body('author.title').optional().isString().trim(),
    body('author.image').optional().isString().trim(),
    body('author.verified').optional().isBoolean(),
    body('body').notEmpty().isString().trim().isLength({ max: 2000 }),
  ],
  (req, res) => {
    if (validationFail(req, res)) return;
    const post = db.getMedicosPost(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const { author, body: commentBody } = req.body;
    const id  = uuidv4();
    const now = new Date().toISOString();

    const comment = db.insertMedicosComment({
      id, postId: req.params.id,
      author: { name: author.name, title: author.title||'', image: author.image||'https://i.pravatar.cc/150?img=1', verified: author.verified??false },
      body: commentBody, upvotes: 1, downvotes: 0, created_at: now,
    });

    db.updateMedicosPost(req.params.id, { comments: (post.comments||0)+1 });
    return res.status(201).json({ ...comment, score: 1, timestamp: relativeTime(comment.created_at) });
  }
);

// â”€â”€ POST /api/medicos/comments/:id/vote â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.post('/comments/:id/vote', [param('id').notEmpty()], (req, res) => {
  if (validationFail(req, res)) return;
  const comment = db.getMedicosCommentById(req.params.id);
  if (!comment) return res.status(404).json({ message: 'Comment not found' });

  const direction = req.body.direction || 'none';
  const prev      = req.body.prev      || 'none';

  let up   = comment.upvotes   || 1;
  let down = comment.downvotes || 0;
  if (prev === 'up')   up   = Math.max(0, up   - 1);
  if (prev === 'down') down = Math.max(0, down - 1);
  if (direction === 'up')   up   += 1;
  if (direction === 'down') down += 1;

  db.updateMedicosComment(req.params.id, { upvotes: up, downvotes: down });
  return res.json({ id: req.params.id, upvotes: up, downvotes: down, score: up - down });
});

// â”€â”€ GET /api/medicos/communities â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
router.get('/communities', (_req, res) => {
  const communities = [
    { name: 'Cardiology',     icon: 'â¤ï¸',  members: 18400, color: '#EF4444' },
    { name: 'Dermatology',    icon: 'ðŸ©º',  members: 12200, color: '#F59E0B' },
    { name: 'Neurology',      icon: 'ðŸ§ ',  members: 15700, color: '#8B5CF6' },
    { name: 'Ophthalmology',  icon: 'ðŸ‘ï¸',  members: 9300,  color: '#06B6D4' },
    { name: 'Dentistry',      icon: 'ðŸ¦·',  members: 11100, color: '#10B981' },
    { name: 'Orthopedics',    icon: 'ðŸ¦´',  members: 8900,  color: '#F97316' },
    { name: 'Pediatrics',     icon: 'ðŸ‘¶',  members: 14200, color: '#EC4899' },
    { name: 'Psychiatry',     icon: 'ðŸ§©',  members: 10600, color: '#6366F1' },
    { name: 'Oncology',       icon: 'ðŸŽ—ï¸',  members: 7800,  color: '#84CC16' },
    { name: 'Endocrinology',  icon: 'ðŸ’‰',  members: 6500,  color: '#14B8A6' },
  ];
  const posts = db.getMedicosPosts(10000, 0);
  const result = communities.map(c => {
    const cl = c.name.toLowerCase();
    const count = posts.filter(p =>
      (p.specialty||'').toLowerCase() === cl ||
      (p.tags||[]).some(t => t.toLowerCase().includes(cl.slice(0,5)))
    ).length;
    return { ...c, postCount: count };
  });
  return res.json({ communities: result });
});

// backwards compat alias
router.get('/specialties', (_req, res) => res.redirect(307, '/api/medicos/communities'));

module.exports = router;
