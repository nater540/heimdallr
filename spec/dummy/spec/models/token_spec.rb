describe Token do
  context 'database structure' do
    it { should have_db_column(:id).of_type(:uuid) }
    it { should have_db_column(:application_id).of_type(:uuid) }
    it { should have_db_column(:scopes).of_type(:string) }
    it { should have_db_column(:data).of_type(:jsonb) }
    it { should have_db_column(:ip).of_type(:inet) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:expires_at).of_type(:datetime) }
    it { should have_db_column(:revoked_at).of_type(:datetime) }
    it { should have_db_column(:not_before).of_type(:datetime) }
  end

  let(:application) do
    Heimdallr::CreateApplication.new(
      name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
      scopes: 'users:create users:update tokens:delete universe:implode shiba:pet',
      algorithm: 'HS256'
    ).call
  end

  subject { Heimdallr::CreateToken.new(application: application, scopes: %w[users:create universe:implode shiba:pet], expires_at: 30.minutes.from_now).call }

  describe '#scopes=' do
    it 'converts a string to an array' do
      subject.scopes = 'users:create universe:implode'
      expect(subject.scopes).to match_array %w[users:create universe:implode]
    end

    it 'removes duplicate values' do
      subject.scopes = %w[users:create universe:implode users:create users:create universe:implode]
      expect(subject.scopes).to match_array %w[users:create universe:implode]
    end
  end

  describe '#has_scopes?' do
    it 'returns true when the scopes do exist' do
      expect(subject.has_scopes?('universe:implode', 'shiba:pet')).to be_truthy
    end

    it 'returns false when the scopes do NOT exist' do
      expect(subject.has_scopes?('universe:create', 'shiba:pet')).to be_falsey
    end
  end

  describe '#remove_scopes' do
    it 'removes a single scope' do
      subject.remove_scopes('users:create')
      expect(subject.scopes).to match_array %w[universe:implode shiba:pet]
    end

    it 'removes multiple scopes' do
      subject.remove_scopes('users:create', 'universe:implode', 'scope:does:not:exist')
      expect(subject.scopes).to match_array %w[shiba:pet]
    end
  end

  describe '#revoke!' do
    let(:to_revoke) { Heimdallr::CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call }

    it 'has exactly one error after being revoked' do
      to_revoke.revoke!
      to_revoke.reload

      expect(to_revoke.token_errors).to match_array ['This token has been revoked. Please acquire a new token and try your request again.']
    end
  end

  describe '#refresh!' do
    it 'refreshes the token by 15 minutes' do
      current_expiration = subject.expires_at
      subject.refresh!(amount: 15.minutes)

      expect(subject.expires_at).to eq(current_expiration + 15.minutes)
    end
  end

  describe '#encode' do
    context 'with a token that has been persisted to the database' do
      it 'encodes to a JWT string' do
        expect(subject.encode).to be_a(String)
      end
    end

    context 'with a token that has NOT been persisted to the database' do
      it 'raises an exception when encoding' do
        expect { Token.new(application: application, scopes: %w[users:create]).encode }.to raise_error(StandardError, 'Token must be persisted to the database before encoded.')
      end
    end
  end
end
