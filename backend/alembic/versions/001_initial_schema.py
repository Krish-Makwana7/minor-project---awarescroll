"""Initial database schema for AwareScroll AI + FocusLock

Revision ID: 001_initial
Revises: 
Create Date: 2026-10-19 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '001_initial'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # 1. users
    op.create_table(
        'users',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, unique=True),
        sa.Column('password_hash', sa.String(255), nullable=False),
        sa.Column('timezone', sa.String(64), nullable=False, server_default='UTC'),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_users_email', 'users', ['email'])

    # 2. goals
    op.create_table(
        'goals',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('goal_type', sa.String(64), nullable=False),
        sa.Column('target_value', sa.Float(), nullable=False),
        sa.Column('unit', sa.String(32), nullable=False, server_default='minutes'),
        sa.Column('active', sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_goals_user_id', 'goals', ['user_id'])

    # 3. intentions
    op.create_table(
        'intentions',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('session_type', sa.String(32), nullable=False),
        sa.Column('intended_duration_minutes', sa.Integer(), nullable=False),
        sa.Column('intended_purpose', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_intentions_user_id', 'intentions', ['user_id'])

    # 4. usage_sessions
    op.create_table(
        'usage_sessions',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('intention_id', sa.CHAR(36), sa.ForeignKey('intentions.id', ondelete='SET NULL'), nullable=True),
        sa.Column('start_time', sa.DateTime(), nullable=False),
        sa.Column('end_time', sa.DateTime(), nullable=True),
        sa.Column('actual_duration_minutes', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('exceeded_limit', sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column('reminder_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('time_of_day_bucket', sa.String(32), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_usage_sessions_user_id', 'usage_sessions', ['user_id'])
    op.create_index('ix_usage_sessions_intention_id', 'usage_sessions', ['intention_id'])

    # 5. focus_sessions
    op.create_table(
        'focus_sessions',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('intention_id', sa.CHAR(36), sa.ForeignKey('intentions.id', ondelete='SET NULL'), nullable=True),
        sa.Column('task_category', sa.String(64), nullable=False),
        sa.Column('task_description', sa.String(255), nullable=False),
        sa.Column('planned_duration_minutes', sa.Integer(), nullable=False),
        sa.Column('start_time', sa.DateTime(), nullable=False),
        sa.Column('end_time', sa.DateTime(), nullable=True),
        sa.Column('completed', sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column('interrupted', sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_focus_sessions_user_id', 'focus_sessions', ['user_id'])
    op.create_index('ix_focus_sessions_intention_id', 'focus_sessions', ['intention_id'])

    # 6. interruptions
    op.create_table(
        'interruptions',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('focus_session_id', sa.CHAR(36), sa.ForeignKey('focus_sessions.id', ondelete='CASCADE'), nullable=False),
        sa.Column('interruption_time', sa.DateTime(), nullable=False),
        sa.Column('reason_text', sa.Text(), nullable=False),
        sa.Column('reason_category', sa.String(32), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_interruptions_focus_session_id', 'interruptions', ['focus_session_id'])

    # 7. work_evidence
    op.create_table(
        'work_evidence',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('focus_session_id', sa.CHAR(36), sa.ForeignKey('focus_sessions.id', ondelete='CASCADE'), nullable=False),
        sa.Column('image_url', sa.String(512), nullable=False),
        sa.Column('uploaded_at', sa.DateTime(), nullable=False),
        sa.Column('verification_status', sa.String(32), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_work_evidence_focus_session_id', 'work_evidence', ['focus_session_id'])

    # 8. feedback
    op.create_table(
        'feedback',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('usage_session_id', sa.CHAR(36), sa.ForeignKey('usage_sessions.id', ondelete='CASCADE'), nullable=False, unique=True),
        sa.Column('original_intention', sa.Text(), nullable=True),
        sa.Column('continuation_motivation', sa.String(255), nullable=False),
        sa.Column('content_type', sa.String(255), nullable=False),
        sa.Column('delayed_planned_work', sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column('mood_after', sa.String(64), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_feedback_usage_session_id', 'feedback', ['usage_session_id'])

    # 9. behavioral_events
    op.create_table(
        'behavioral_events',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('event_source', sa.String(32), nullable=False),
        sa.Column('event_type', sa.String(64), nullable=False),
        sa.Column('payload', sa.JSON(), nullable=False),
        sa.Column('occurred_at', sa.DateTime(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_behavioral_events_user_id', 'behavioral_events', ['user_id'])
    op.create_index('ix_behavioral_events_occurred_at', 'behavioral_events', ['occurred_at'])

    # 10. predictions
    op.create_table(
        'predictions',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('model_type', sa.String(32), nullable=False),
        sa.Column('target', sa.String(32), nullable=False),
        sa.Column('predicted_probability', sa.Float(), nullable=False),
        sa.Column('predicted_outcome', sa.Boolean(), nullable=False),
        sa.Column('actual_outcome', sa.Boolean(), nullable=True),
        sa.Column('model_version', sa.String(64), nullable=False, server_default='v1.0.0'),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_predictions_user_id', 'predictions', ['user_id'])

    # 11. recommendations
    op.create_table(
        'recommendations',
        sa.Column('id', sa.CHAR(36), primary_key=True),
        sa.Column('user_id', sa.CHAR(36), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('recommendation_type', sa.String(64), nullable=False),
        sa.Column('recommendation_text', sa.Text(), nullable=False),
        sa.Column('based_on_pattern', sa.Text(), nullable=False),
        sa.Column('shown_at', sa.DateTime(), nullable=False),
        sa.Column('accepted', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
    )
    op.create_index('ix_recommendations_user_id', 'recommendations', ['user_id'])


def downgrade() -> None:
    op.drop_table('recommendations')
    op.drop_table('predictions')
    op.drop_table('behavioral_events')
    op.drop_table('feedback')
    op.drop_table('work_evidence')
    op.drop_table('interruptions')
    op.drop_table('focus_sessions')
    op.drop_table('usage_sessions')
    op.drop_table('intentions')
    op.drop_table('goals')
    op.drop_table('users')
