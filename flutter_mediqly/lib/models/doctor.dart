// ─── Doctor Model ─────────────────────────────────────────────────────────

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String hospital;
  final String city;
  final String image;
  final bool videoAvailable;
  final String onlineStatus;  // 'Online' | 'Offline' | 'Busy'
  final bool homeVisit;
  final int experience;
  final double rating;
  final int reviewsCount;
  final double fee;
  final List<String> languages;
  final bool verified;
  final List<String> tags;
  final int consultationDuration;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.city,
    required this.image,
    required this.videoAvailable,
    required this.onlineStatus,
    required this.homeVisit,
    required this.experience,
    required this.rating,
    required this.reviewsCount,
    required this.fee,
    required this.languages,
    required this.verified,
    required this.tags,
    required this.consultationDuration,
  });
}

const List<Doctor> kDoctors = [
  Doctor(id:1,  name:'Dr. Sarah Collins',  specialty:'Ophthalmologist', hospital:'Grandview Hospital',       city:'New York',    image:'https://i.pravatar.cc/150?img=1',  videoAvailable:true,  onlineStatus:'Online',  homeVisit:true,  experience:12, rating:4.9, reviewsCount:320, fee:150, languages:['English','Spanish'], verified:true,  tags:['Top Rated'],              consultationDuration:20),
  Doctor(id:2,  name:'Dr. John Doe',       specialty:'Cardiologist',    hospital:'City General Hospital',    city:'New York',    image:'https://i.pravatar.cc/150?img=2',  videoAvailable:true,  onlineStatus:'Offline', homeVisit:false, experience:15, rating:4.8, reviewsCount:412, fee:200, languages:['English'],           verified:true,  tags:[],                         consultationDuration:15),
  Doctor(id:3,  name:'Dr. Emily White',    specialty:'Dermatologist',   hospital:'Mount Sinai',              city:'New York',    image:'https://i.pravatar.cc/150?img=3',  videoAvailable:false, onlineStatus:'Offline', homeVisit:true,  experience:8,  rating:4.9, reviewsCount:189, fee:175, languages:['English','French'],  verified:false, tags:[],                         consultationDuration:20),
  Doctor(id:4,  name:'Dr. Michael Brown',  specialty:'Cardiologist',    hospital:'LA General',               city:'Los Angeles', image:'https://i.pravatar.cc/150?img=4',  videoAvailable:true,  onlineStatus:'Busy',    homeVisit:false, experience:20, rating:5.0, reviewsCount:890, fee:250, languages:['English'],           verified:true,  tags:['Top Rated','Popular'],    consultationDuration:15),
  Doctor(id:5,  name:'Dr. Jessica Green',  specialty:'Ophthalmologist', hospital:'Cedars-Sinai',             city:'Los Angeles', image:'https://i.pravatar.cc/150?img=5',  videoAvailable:true,  onlineStatus:'Online',  homeVisit:true,  experience:10, rating:4.7, reviewsCount:302, fee:160, languages:['English','Spanish'], verified:false, tags:[],                         consultationDuration:15),
  Doctor(id:6,  name:'Dr. David Wilson',   specialty:'Neurologist',     hospital:'Northwestern Memorial',    city:'Chicago',     image:'https://i.pravatar.cc/150?img=6',  videoAvailable:false, onlineStatus:'Offline', homeVisit:false, experience:18, rating:4.8, reviewsCount:543, fee:220, languages:['English'],           verified:true,  tags:['Specialist'],             consultationDuration:25),
  Doctor(id:7,  name:'Dr. Lisa Chen',      specialty:'Dermatologist',   hospital:'UCLA Medical Center',      city:'Los Angeles', image:'https://i.pravatar.cc/150?img=7',  videoAvailable:true,  onlineStatus:'Online',  homeVisit:false, experience:9,  rating:4.9, reviewsCount:255, fee:180, languages:['English','Mandarin'], verified:true, tags:['Top Rated'],             consultationDuration:15),
  Doctor(id:8,  name:'Dr. Kevin Adams',    specialty:'Dentist',         hospital:'City General Hospital',    city:'New York',    image:'https://i.pravatar.cc/150?img=8',  videoAvailable:false, onlineStatus:'Online',  homeVisit:false, experience:10, rating:4.8, reviewsCount:210, fee:90,  languages:['English'],           verified:true,  tags:['Dental Care'],            consultationDuration:20),
  Doctor(id:9,  name:'Dr. Maria Garcia',   specialty:'Orthodontist',    hospital:'LA General',               city:'Los Angeles', image:'https://i.pravatar.cc/150?img=9',  videoAvailable:false, onlineStatus:'Offline', homeVisit:false, experience:14, rating:4.9, reviewsCount:350, fee:180, languages:['English','Spanish'], verified:true,  tags:['Braces','Top Rated'],     consultationDuration:30),
  Doctor(id:10, name:'Dr. Brian Lee',      specialty:'Dentist',         hospital:'Northwestern Memorial',    city:'Chicago',     image:'https://i.pravatar.cc/150?img=10', videoAvailable:true,  onlineStatus:'Busy',    homeVisit:false, experience:7,  rating:4.7, reviewsCount:155, fee:100, languages:['English','Korean'],  verified:false, tags:[],                         consultationDuration:20),
];
