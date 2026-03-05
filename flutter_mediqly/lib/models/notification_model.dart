// ─── Notification Model ───────────────────────────────────────────────────
// ai-health-passport/components/NotificationToast.tsx

class AppNotification {
  final int id;
  final String type;         // 'reminder' | 'message' | 'record' | 'plan'
  final String title;
  final String description;
  final String timestamp;
  final bool unread;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.unread,
  });
}

// ─── Passport Notification (toast) ──────────────────────────────────────────
// Mirrors Notification from ai-health-passport/components/NotificationToast.tsx

class PassportNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'success' | 'warning' | 'error' | 'info'

  const PassportNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
  });
}

const List<AppNotification> kNotifications = [
  AppNotification(id:1, type:'reminder', title:'Appointment Reminder',  description:'Your appointment with Dr. Sarah Collins is today at 10:30 AM.', timestamp:'5m ago', unread:true),
  AppNotification(id:2, type:'message',  title:'New Message',           description:'Dr. John Doe sent you a message regarding your recent test results.', timestamp:'1h ago', unread:true),
  AppNotification(id:3, type:'record',   title:'Record Updated',        description:'Your blood test results have been added to your medical records.', timestamp:'3h ago', unread:false),
  AppNotification(id:4, type:'plan',     title:'Plan Updated',          description:'Your custom health plan has been updated.', timestamp:'1d ago', unread:false),
];

// ─── Mock feed data ──────────────────────────────────────────────────────────

class MedicosAuthor {
  final String name;
  final String title;
  final String image;
  final bool verified;
  const MedicosAuthor({required this.name, required this.title, required this.image, required this.verified});
}

class MedicosPost {
  final int id;
  final String? backendId; // server UUID (null for local seed data)
  final MedicosAuthor author;
  final String timestamp;
  final String title;
  final String body;
  final String? imageUrl;
  final List<String> tags;
  final String? specialty;
  final String? flair;
  final int upvotes;
  final int downvotes;
  final int score;
  final int comments;
  final int shares;
  final List<Map<String, dynamic>> awards;
  final String? voteDirection; // 'up' | 'down' | null (local UI state)
  const MedicosPost({
    required this.id,
    this.backendId,
    required this.author,
    required this.timestamp,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.tags,
    this.specialty,
    this.flair,
    required this.upvotes,
    required this.downvotes,
    required this.score,
    required this.comments,
    required this.shares,
    this.awards = const [],
    this.voteDirection,
  });

  // backwards-compat getter
  int get likes => upvotes;

  factory MedicosPost.fromJson(Map<String, dynamic> json) {
    final a = json['author'] as Map<String, dynamic>? ?? {};
    final int up   = (json['upvotes']   ?? json['likes'] ?? 0) as int;
    final int down = (json['downvotes'] ?? 0) as int;
    return MedicosPost(
      id:        0,
      backendId: json['id'] as String?,
      author: MedicosAuthor(
        name:     a['name']     as String? ?? '',
        title:    a['title']    as String? ?? '',
        image:    a['image']    as String? ?? 'https://i.pravatar.cc/150?img=1',
        verified: a['verified'] as bool?   ?? false,
      ),
      timestamp:     json['timestamp']  as String? ?? 'just now',
      title:         json['title']      as String? ?? '',
      body:          json['body']       as String? ?? '',
      imageUrl:      json['imageUrl']   as String?,
      tags:          List<String>.from(json['tags'] ?? []),
      specialty:     json['specialty']  as String?,
      flair:         json['flair']      as String?,
      upvotes:       up,
      downvotes:     down,
      score:         (json['score']     ?? up - down) as int,
      comments:      (json['comments']  ?? 0) as int,
      shares:        (json['shares']    ?? 0) as int,
      awards:        List<Map<String, dynamic>>.from(
                       (json['awards'] as List<dynamic>? ?? [])
                           .map((e) => Map<String, dynamic>.from(e as Map))),
    );
  }

  MedicosPost copyWith({
    int? upvotes, int? downvotes, int? score,
    int? comments, int? shares,
    List<Map<String,dynamic>>? awards,
    String? voteDirection,
    // compat
    int? likes,
  }) => MedicosPost(
    id:            id,
    backendId:     backendId,
    author:        author,
    timestamp:     timestamp,
    title:         title,
    body:          body,
    imageUrl:      imageUrl,
    tags:          tags,
    specialty:     specialty,
    flair:         flair,
    upvotes:       upvotes   ?? likes ?? this.upvotes,
    downvotes:     downvotes ?? this.downvotes,
    score:         score     ?? this.score,
    comments:      comments  ?? this.comments,
    shares:        shares    ?? this.shares,
    awards:        awards    ?? this.awards,
    voteDirection: voteDirection ?? this.voteDirection,
  );
}

class VideoDoctor {
  final String name;
  final String image;
  final bool verified;
  const VideoDoctor({required this.name, required this.image, required this.verified});
}

class MedistreamVideo {
  final int id;
  final bool featured;
  final String thumbnailUrl;
  final String title;
  final VideoDoctor doctor;
  final String duration;
  final String views;
  final String uploadDate;
  const MedistreamVideo({required this.id, this.featured = false, required this.thumbnailUrl, required this.title, required this.doctor, required this.duration, required this.views, required this.uploadDate});
}

const List<MedicosPost> kMedicosFeed = [
  MedicosPost(id:1, author:MedicosAuthor(name:'Dr. Sunita Rao',   title:'Senior Cardiologist',            image:'https://i.pravatar.cc/150?img=49', verified:true),  timestamp:'2h ago', specialty:'Cardiology',  flair:'Case Study',  title:'Challenging Case: Post-Angioplasty Complications',              body:'A 58-year-old male presented with recurrent chest pain two weeks post-angioplasty. Initial ECG attached. Thoughts on management strategy?', imageUrl:'https://i.imgur.com/8Q1Z2Yt.png',   tags:['#Cardiology','#CaseStudy','#ECG'],             upvotes:136, downvotes:8,  score:128, comments:42,  shares:15, awards:[{'type':'helpful','count':2}]),
  MedicosPost(id:2, author:MedicosAuthor(name:'Dr. Amit Verma',   title:'Junior Doctor, Internal Medicine', image:'https://i.pravatar.cc/150?img=53', verified:false), timestamp:'5h ago', specialty:'Dermatology', flair:'Discussion',  title:'Unexplained Hypokalemia in a Young Adult',                      body:"Patient (24F) with persistent hypokalemia despite potassium supplements. Renal function is normal. No history of diuretic use. What are the next diagnostic steps?",                              tags:['#InternalMedicine','#Diagnostics'],             upvotes:83,  downvotes:7,  score:76,  comments:29,  shares:5,  awards:[]),
  MedicosPost(id:3, author:MedicosAuthor(name:'Dr. Priya Sharma', title:'Dermatologist',                  image:'https://i.pravatar.cc/150?img=45', verified:true),  timestamp:'1d ago', specialty:'Dermatology', flair:'Case Study',  title:'Unusual Rash After Starting a New Biologic',                    body:"Attached is an image of a rash that appeared on a patient's torso 3 days after initiating a new biologic for psoriasis.",                        imageUrl:'https://i.imgur.com/O3s5p0L.jpeg', tags:['#Dermatology','#DrugReaction'],                upvotes:228, downvotes:13, score:215, comments:88,  shares:21, awards:[{'type':'insightful','count':1}]),
  MedicosPost(id:4, author:MedicosAuthor(name:'Dr. Rajesh Kumar', title:'Neurologist',                    image:'https://i.pravatar.cc/150?img=58', verified:true),  timestamp:'2d ago', specialty:'Neurology',   flair:'Research',    title:"Discussion: Latest advancements in Alzheimer's treatment",      body:"Let's discuss the potential and limitations of the new monoclonal antibody treatments for early-stage Alzheimer's disease. What are your clinical experiences so far?",                        tags:['#Neurology','#Alzheimers','#Research'],         upvotes:320, downvotes:18, score:302, comments:112, shares:45, awards:[{'type':'gold','count':1},{'type':'helpful','count':4}]),
];

const List<MedistreamVideo> kMedistreamFeed = [
  MedistreamVideo(id:1, featured:true, thumbnailUrl:'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', title:'Understanding Common Cold Symptoms', doctor:VideoDoctor(name:'Dr. Julia Roberts', image:'https://i.pravatar.cc/150?img=47', verified:true), duration:'0:30', views:'15K views', uploadDate:'2 weeks ago'),
  MedistreamVideo(id:2, thumbnailUrl:'https://images.pexels.com/photos/5452291/pexels-photo-5452291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', title:'Tips to Relieve Acid Reflux', doctor:VideoDoctor(name:'Dr. Rajesh Patel', image:'https://i.pravatar.cc/150?img=58', verified:true), duration:'8:33', views:'8.3K views', uploadDate:'1 month ago'),
  MedistreamVideo(id:3, thumbnailUrl:'https://images.pexels.com/photos/4226256/pexels-photo-4226256.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', title:'How to Manage Stress Effectively', doctor:VideoDoctor(name:'Dr. Sameer Khan', image:'https://i.pravatar.cc/150?img=60', verified:true), duration:'8:30', views:'20K views', uploadDate:'1 month ago'),
  MedistreamVideo(id:4, thumbnailUrl:'https://images.pexels.com/photos/3985163/pexels-photo-3985163.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', title:'Benefits of a Morning Walk', doctor:VideoDoctor(name:'Dr. John Miller', image:'https://i.pravatar.cc/150?img=8', verified:false), duration:'12:00', views:'12K views', uploadDate:'1 month ago'),
  MedistreamVideo(id:5, thumbnailUrl:'https://images.pexels.com/photos/4167544/pexels-photo-4167544.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', title:'Easy At-Home Exercises', doctor:VideoDoctor(name:'Dr. John Miller', image:'https://i.pravatar.cc/150?img=8', verified:false), duration:'12:00', views:'12K views', uploadDate:'1 month ago'),
];

// Insurance mock data
class InsurancePolicy {
  final int id;
  final String name;
  final String provider;
  final String policyNumber;
  final int coverage;
  final int premium;
  final String renewal;
  final String type;
  const InsurancePolicy({required this.id, required this.name, required this.provider, required this.policyNumber, required this.coverage, required this.premium, required this.renewal, required this.type});
}

const List<InsurancePolicy> kUserPolicies = [
  InsurancePolicy(id:1, name:'Family Health Shield',  provider:'LifeSecure Inc.', policyNumber:'LSI-12345-HS', coverage:500000, premium:1200, renewal:'2025-08-15', type:'Health'),
  InsurancePolicy(id:2, name:'Critical Care Plus',    provider:'MediTrust',       policyNumber:'MT-67890-CC',  coverage:250000, premium:600,  renewal:'2025-10-20', type:'Critical Illness'),
  InsurancePolicy(id:3, name:'SecureLife Term Plan',  provider:'LifeSecure Inc.', policyNumber:'LSI-54321-TP', coverage:1000000,premium:800,  renewal:'2026-01-10', type:'Life'),
];
