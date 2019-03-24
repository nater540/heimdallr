describe JwtApplication do
  context 'database structure' do
    it { should have_db_column(:id).of_type(:uuid) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:key).of_type(:string) }
    it { should have_db_column(:scopes).of_type(:string) }
    it { should have_db_column(:secret).of_type(:string) }
    it { should have_db_column(:certificate).of_type(:text) }
    it { should have_db_column(:algorithm).of_type(:enum) }
    it { should have_db_column(:ip).of_type(:inet) }
  end

  subject do
    Heimdallr::CreateApplication.new(
      name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
      scopes: 'users:create users:update tokens:delete universe:implode',
      algorithm: 'RS256'
    ).call
  end

  context 'model validations' do
    it { expect(subject).to validate_presence_of(:scopes) }
  end

  describe '#regenerate_secret!' do
    it 'generates a new secret value and persists to the database' do
      old_secret = subject.secret
      subject.regenerate_secret!

      expect(subject.secret).not_to eq(old_secret)
      expect(subject.secret_changed?).to be_falsey
    end
  end

  describe '#regenerate_secret' do
    it 'generates a new secret value but does not persist to the database' do
      old_secret = subject.secret
      subject.regenerate_secret

      expect(subject.secret).not_to eq(old_secret)
      expect(subject.secret_changed?).to be_truthy
    end
  end

  describe '#regenerate_certificate!' do
    it 'generates a new certificate and persists to the database' do
      old_certificate = subject.certificate
      subject.regenerate_certificate!

      expect(subject.certificate).not_to eq(old_certificate)
      expect(subject.certificate_changed?).to be_falsey
    end
  end

  describe '#regenerate_certificate' do
    it 'generates a new certificate but does not persist to the database' do
      old_certificate = subject.certificate
      subject.regenerate_certificate

      expect(subject.certificate).not_to eq(old_certificate)
      expect(subject.certificate_changed?).to be_truthy
    end
  end

  describe '#rsa' do
    it 'returns an RSA certificate' do
      expect(subject.rsa).to be_a(OpenSSL::PKey::RSA)
    end
  end
end
