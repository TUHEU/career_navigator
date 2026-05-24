// l10n/app_strings.dart
// Complete bilingual string table — EN + FR
// Usage: context.read<LanguageProvider>().t('key')

class S {
  // ── Auth ─────────────────────────────────────────────────
  static const signIn           = 'signIn';
  static const signUp           = 'signUp';
  static const email            = 'email';
  static const password         = 'password';
  static const forgotPassword   = 'forgotPassword';
  static const createAccount    = 'createAccount';
  static const alreadyAccount   = 'alreadyAccount';
  static const dontHaveAccount  = 'dontHaveAccount';
  static const verifyEmail      = 'verifyEmail';
  static const verifyEmailSub   = 'verifyEmailSub';
  static const verifyBtn        = 'verifyBtn';
  static const resend           = 'resend';
  static const didntReceive     = 'didntReceive';
  static const backToSignIn     = 'backToSignIn';
  static const logout           = 'logout';
  static const continueAsGuest  = 'continueAsGuest';
  static const guestWarning     = 'guestWarning';

  // ── Onboarding ───────────────────────────────────────────
  static const skip             = 'skip';
  static const next             = 'next';
  static const getStarted       = 'getStarted';
  static const onboard1Tag      = 'onboard1Tag';
  static const onboard1Title    = 'onboard1Title';
  static const onboard1Sub      = 'onboard1Sub';
  static const onboard2Tag      = 'onboard2Tag';
  static const onboard2Title    = 'onboard2Title';
  static const onboard2Sub      = 'onboard2Sub';
  static const onboard3Tag      = 'onboard3Tag';
  static const onboard3Title    = 'onboard3Title';
  static const onboard3Sub      = 'onboard3Sub';

  // ── Dashboard ────────────────────────────────────────────
  static const welcomeBack      = 'welcomeBack';
  static const editProfile      = 'editProfile';
  static const aiCareerTools    = 'aiCareerTools';
  static const aiCareerSub      = 'aiCareerSub';
  static const moreComing       = 'moreComing';
  static const moreComingSub    = 'moreComingSub';
  static const jobSeeker        = 'jobSeeker';
  static const mentor           = 'mentor';
  static const admin            = 'admin';

  // ── Jobs ─────────────────────────────────────────────────
  static const jobs             = 'jobs';
  static const searchJobs       = 'searchJobs';
  static const applyNow         = 'applyNow';
  static const applied          = 'applied';
  static const noJobs           = 'noJobs';

  // ── Profile ──────────────────────────────────────────────
  static const myProfile        = 'myProfile';
  static const fullName         = 'fullName';
  static const location         = 'location';
  static const bio              = 'bio';
  static const skills           = 'skills';
  static const experience       = 'experience';
  static const education        = 'education';
  static const save             = 'save';
  static const cancel           = 'cancel';
  static const changePhoto      = 'changePhoto';
  static const profileSetup     = 'profileSetup';
  static const completeProfile  = 'completeProfile';
  static const iAm              = 'iAm';
  static const finishReg        = 'finishReg';
  static const dateOfBirth      = 'dateOfBirth';

  // ── Settings ─────────────────────────────────────────────
  static const settings         = 'settings';
  static const appearance       = 'appearance';
  static const darkMode         = 'darkMode';
  static const language         = 'language';
  static const account          = 'account';
  static const support          = 'support';
  static const helpFaq          = 'helpFaq';
  static const aboutUs          = 'aboutUs';
  static const privacyPolicy    = 'privacyPolicy';
  static const sendFeedback     = 'sendFeedback';
  static const changePassword   = 'changePassword';
  static const deleteAccount    = 'deleteAccount';
  static const chooseLanguage   = 'chooseLanguage';

  // ── AI ───────────────────────────────────────────────────
  static const aiHub            = 'aiHub';
  static const analyze          = 'analyze';
  static const analyzing        = 'analyzing';

  // ── Navigation ───────────────────────────────────────────
  static const home             = 'home';
  static const chat             = 'chat';
  static const search           = 'search';
  static const notifications    = 'notifications';

  // ── General ──────────────────────────────────────────────
  static const loading          = 'loading';
  static const error            = 'error';
  static const success          = 'success';
  static const retry            = 'retry';
  static const noData           = 'noData';
  static const confirm          = 'confirm';
  static const guestMode        = 'guestMode';
  static const guestModeDesc    = 'guestModeDesc';
  static const signInToAccess   = 'signInToAccess';
}

// ── English strings ──────────────────────────────────────────
const Map<String, String> enStrings = {
  S.signIn:          'Sign In',
  S.signUp:          'Sign Up',
  S.email:           'Email Address',
  S.password:        'Password',
  S.forgotPassword:  'Forgot Password?',
  S.createAccount:   'Create Account',
  S.alreadyAccount:  'Already have an account?',
  S.dontHaveAccount: "Don't have an account?",
  S.verifyEmail:     'Verify Your Email',
  S.verifyEmailSub:  'We sent a 6-digit verification code to',
  S.verifyBtn:       'VERIFY EMAIL',
  S.resend:          'Resend',
  S.didntReceive:    "Didn't receive the code?",
  S.backToSignIn:    '← Back to Sign In',
  S.logout:          'Logout',
  S.continueAsGuest: 'Continue as Guest',
  S.guestWarning:    'Limited access — some features require an account',

  S.skip:            'SKIP',
  S.next:            'Next',
  S.getStarted:      'Get Started',
  S.onboard1Tag:     'SMART JOB MATCHING',
  S.onboard1Title:   'Find Your\nDream Career',
  S.onboard1Sub:     'Browse hundreds of opportunities tailored to your skills, location, and ambitions.',
  S.onboard2Tag:     'EXPERT MENTORSHIP',
  S.onboard2Title:   'Learn From\nIndustry Leaders',
  S.onboard2Sub:     'Connect with mentors who have walked the path you want to take.',
  S.onboard3Tag:     'AI CAREER TOOLS',
  S.onboard3Title:   'AI-Powered\nCareer Advisor',
  S.onboard3Sub:     'Analyze your career path, negotiate better salaries, and craft impactful messages.',

  S.welcomeBack:     'Welcome back',
  S.editProfile:     'Edit Profile',
  S.aiCareerTools:   'AI Career Tools',
  S.aiCareerSub:     'Career paths, salary negotiation, review coach...',
  S.moreComing:      'More features coming soon',
  S.moreComingSub:   'AI recommendations & skill assessments.',
  S.jobSeeker:       'Job Seeker',
  S.mentor:          'Mentor',
  S.admin:           'Admin',

  S.jobs:            'Jobs',
  S.searchJobs:      'Search jobs...',
  S.applyNow:        'Apply Now',
  S.applied:         'Applied',
  S.noJobs:          'No jobs found',

  S.myProfile:       'My Profile',
  S.fullName:        'Full Name',
  S.location:        'Location',
  S.bio:             'Bio',
  S.skills:          'Skills',
  S.experience:      'Experience',
  S.education:       'Education',
  S.save:            'Save',
  S.cancel:          'Cancel',
  S.changePhoto:     'Change Photo',
  S.profileSetup:    'Profile Setup',
  S.completeProfile: 'Complete Your Profile',
  S.iAm:             'I am a...',
  S.finishReg:       'FINISH REGISTRATION',
  S.dateOfBirth:     'Date of Birth',

  S.settings:        'Settings',
  S.appearance:      'Appearance',
  S.darkMode:        'Dark Mode',
  S.language:        'Language',
  S.account:         'Account',
  S.support:         'Support',
  S.helpFaq:         'Help & FAQ',
  S.aboutUs:         'About Us',
  S.privacyPolicy:   'Privacy Policy',
  S.sendFeedback:    'Send Feedback',
  S.changePassword:  'Change Password',
  S.deleteAccount:   'Delete Account',
  S.chooseLanguage:  'Choose Language',

  S.aiHub:           'AI Career Tools',
  S.analyze:         'Analyze',
  S.analyzing:       'Analyzing...',

  S.home:            'Home',
  S.chat:            'Chat',
  S.search:          'Search',
  S.notifications:   'Notifications',

  S.loading:         'Loading...',
  S.error:           'Error',
  S.success:         'Success',
  S.retry:           'Retry',
  S.noData:          'Nothing here yet',
  S.confirm:         'Confirm',
  S.guestMode:       'Guest Mode',
  S.guestModeDesc:   'You\'re browsing as a guest. Sign in for full access.',
  S.signInToAccess:  'Sign in to access this feature',
};

// ── French strings ───────────────────────────────────────────
const Map<String, String> frStrings = {
  S.signIn:          'Se connecter',
  S.signUp:          "S'inscrire",
  S.email:           'Adresse email',
  S.password:        'Mot de passe',
  S.forgotPassword:  'Mot de passe oublié ?',
  S.createAccount:   'Créer un compte',
  S.alreadyAccount:  'Vous avez déjà un compte ?',
  S.dontHaveAccount: "Vous n'avez pas de compte ?",
  S.verifyEmail:     'Vérifiez votre email',
  S.verifyEmailSub:  'Nous avons envoyé un code à 6 chiffres à',
  S.verifyBtn:       "VÉRIFIER L'EMAIL",
  S.resend:          'Renvoyer',
  S.didntReceive:    "Vous n'avez pas reçu le code ?",
  S.backToSignIn:    '← Retour à la connexion',
  S.logout:          'Déconnexion',
  S.continueAsGuest: 'Continuer en tant qu\'invité',
  S.guestWarning:    'Accès limité — certaines fonctionnalités nécessitent un compte',

  S.skip:            'IGNORER',
  S.next:            'Suivant',
  S.getStarted:      'Commencer',
  S.onboard1Tag:     'OFFRES D\'EMPLOI',
  S.onboard1Title:   'Trouvez votre\ncarrière idéale',
  S.onboard1Sub:     'Parcourez des centaines d\'opportunités adaptées à vos compétences et ambitions.',
  S.onboard2Tag:     'MENTORAT EXPERT',
  S.onboard2Title:   'Apprenez des\nleaders du secteur',
  S.onboard2Sub:     'Connectez-vous avec des mentors qui ont emprunté le chemin que vous souhaitez suivre.',
  S.onboard3Tag:     'OUTILS IA CARRIÈRE',
  S.onboard3Title:   'Conseiller\ncarrière IA',
  S.onboard3Sub:     'Analysez votre parcours, négociez de meilleurs salaires et rédigez des messages percutants.',

  S.welcomeBack:     'Bon retour',
  S.editProfile:     'Modifier le profil',
  S.aiCareerTools:   'Outils IA Carrière',
  S.aiCareerSub:     'Parcours, négociation salariale, coach...',
  S.moreComing:      'Plus de fonctionnalités à venir',
  S.moreComingSub:   'Recommandations IA & évaluations de compétences.',
  S.jobSeeker:       'Chercheur d\'emploi',
  S.mentor:          'Mentor',
  S.admin:           'Administrateur',

  S.jobs:            'Emplois',
  S.searchJobs:      'Rechercher des emplois...',
  S.applyNow:        'Postuler',
  S.applied:         'Postulé',
  S.noJobs:          'Aucun emploi trouvé',

  S.myProfile:       'Mon profil',
  S.fullName:        'Nom complet',
  S.location:        'Localisation',
  S.bio:             'Biographie',
  S.skills:          'Compétences',
  S.experience:      'Expérience',
  S.education:       'Éducation',
  S.save:            'Enregistrer',
  S.cancel:          'Annuler',
  S.changePhoto:     'Changer la photo',
  S.profileSetup:    'Configuration du profil',
  S.completeProfile: 'Complétez votre profil',
  S.iAm:             'Je suis un(e)...',
  S.finishReg:       'TERMINER L\'INSCRIPTION',
  S.dateOfBirth:     'Date de naissance',

  S.settings:        'Paramètres',
  S.appearance:      'Apparence',
  S.darkMode:        'Mode sombre',
  S.language:        'Langue',
  S.account:         'Compte',
  S.support:         'Support',
  S.helpFaq:         'Aide & FAQ',
  S.aboutUs:         'À propos',
  S.privacyPolicy:   'Politique de confidentialité',
  S.sendFeedback:    'Envoyer un avis',
  S.changePassword:  'Changer le mot de passe',
  S.deleteAccount:   'Supprimer le compte',
  S.chooseLanguage:  'Choisir la langue',

  S.aiHub:           'Outils IA Carrière',
  S.analyze:         'Analyser',
  S.analyzing:       'Analyse en cours...',

  S.home:            'Accueil',
  S.chat:            'Discussion',
  S.search:          'Recherche',
  S.notifications:   'Notifications',

  S.loading:         'Chargement...',
  S.error:           'Erreur',
  S.success:         'Succès',
  S.retry:           'Réessayer',
  S.noData:          'Rien ici pour le moment',
  S.confirm:         'Confirmer',
  S.guestMode:       'Mode invité',
  S.guestModeDesc:   'Vous naviguez en tant qu\'invité. Connectez-vous pour un accès complet.',
  S.signInToAccess:  'Connectez-vous pour accéder à cette fonctionnalité',
};
