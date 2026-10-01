class UserSerializer < ApplicationSerializer
  def as_json
    {
      id: record.id,
      name: record.name,
      email: record.email,
      created_at: record.created_at.iso8601
    }
  end
end
